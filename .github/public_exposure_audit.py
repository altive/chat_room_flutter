"""一度限りの公開情報監査。GET、Git読取、ローカルスキャン以外は行わない。"""
from __future__ import annotations

import base64
import concurrent.futures
import datetime as dt
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import tarfile
import urllib.error
import urllib.parse
import urllib.request
import zipfile

REPO = "altive/altive-chat"
API = "https://api.github.com/repos/" + REPO
ROOT = Path(os.environ["RUNNER_TEMP"]) / "public-exposure-audit"
ROOT.mkdir(parents=True, exist_ok=True)
TOKEN = os.environ.get("GH_TOKEN", "")
CERTIFICATE = os.environ["AUDIT_REPORT_CERTIFICATE"]
BINARY_URL = "https://github.com/gitleaks/gitleaks/releases/download/v8.30.1/gitleaks_8.30.1_linux_x64.tar.gz"
BINARY_SHA256 = "551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb"
MAX_DOWNLOAD = 64 * 1024 * 1024
MAX_MEMBER = 32 * 1024 * 1024
MAX_ARCHIVE = 256 * 1024 * 1024
MAX_TOTAL_LOGS = 1024 * 1024 * 1024
summary: dict = {"repository": REPO, "started_utc": dt.datetime.now(dt.timezone.utc).isoformat()}
details: dict = {"limitations": [], "findings": {}, "supplemental_matches": []}


def request(url: str, data: bytes | None = None) -> bytes:
    """認証ヘッダーはGitHub APIへの初回リクエストに限定し、リダイレクトへ転送しない。"""
    if urllib.parse.urlsplit(url).scheme != "https":
        raise ValueError("HTTPS required")
    req = urllib.request.Request(url, data=data, headers={
        "Accept": "application/vnd.github+json", "User-Agent": "Altive-public-exposure-audit",
        "X-GitHub-Api-Version": "2022-11-28",
    })
    if TOKEN and urllib.parse.urlsplit(url).hostname == "api.github.com":
        req.add_unredirected_header("Authorization", "Bearer " + TOKEN)
    if data is not None:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=60) as response:
        result = response.read(MAX_DOWNLOAD + 1)
    if len(result) > MAX_DOWNLOAD:
        raise ValueError("download size limit")
    return result


def api_json(path: str) -> object:
    return json.loads(request(API + path))


def page_all(path: str, key: str | None = None) -> list:
    output = []
    for page in range(1, 101):
        sep = "&" if "?" in path else "?"
        payload = api_json(path + sep + f"per_page=100&page={page}")
        items = payload[key] if key else payload
        if not isinstance(items, list):
            raise ValueError("unexpected collection")
        output.extend(items)
        if len(items) < 100:
            return output
    raise ValueError("pagination limit")


def limitation(label: str, error: Exception | str) -> None:
    # エラー本文・URLには未検証の値が含まれ得るので、種類とHTTPコードだけを保持する。
    status = getattr(error, "code", None)
    details["limitations"].append({"scope": label, "error": type(error).__name__ if isinstance(error, Exception) else error, "http_status": status})


def command(args: list[str], **kwargs) -> bytes:
    result = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)
    if result.returncode:
        raise RuntimeError("command failed: " + args[0])
    return result.stdout


def save_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")


def collect_metadata() -> tuple[list, list, list]:
    meta = ROOT / "metadata"
    meta.mkdir(exist_ok=True)
    collections = {}
    endpoints = {
        "issues_and_prs": ("/issues?state=all", None),
        "issue_comments": ("/issues/comments", None),
        "review_comments": ("/pulls/comments", None),
        "commit_comments": ("/comments", None),
        "releases": ("/releases", None),
        "workflow_runs": ("/actions/runs", "workflow_runs"),
        "workflow_artifacts": ("/actions/artifacts", "artifacts"),
    }
    for name, (path, key) in endpoints.items():
        try:
            rows = page_all(path, key)
            collections[name] = rows
            save_json(meta / (name + ".json"), rows)
        except Exception as exc:
            limitation(name, exc)
            collections[name] = []
    reviews = []
    for issue in collections["issues_and_prs"]:
        if "pull_request" in issue:
            try:
                reviews.extend(page_all(f"/pulls/{issue['number']}/reviews"))
            except Exception as exc:
                limitation(f"pr_reviews_{issue['number']}", exc)
    collections["reviews"] = reviews
    save_json(meta / "reviews.json", reviews)
    summary["github_items"] = {name: len(rows) for name, rows in collections.items()}
    # DiscussionsはGraphQLの読取queryのみ。mutationは使用しない。
    try:
        query = '''query { repository(owner: "altive", name: "altive-chat") {
          discussions(first: 100) { pageInfo { hasNextPage } nodes {
            number title body comments(first:100) { pageInfo {hasNextPage} nodes {
              body replies(first:100) { pageInfo {hasNextPage} nodes {body} }
            } }
          } }
        } }'''
        payload = json.loads(request("https://api.github.com/graphql", json.dumps({"query": query}).encode()))
        if payload.get("errors"):
            raise ValueError("GraphQL read unavailable")
        discussions = payload["data"]["repository"]["discussions"]
        save_json(meta / "discussions.json", discussions)
        summary["github_items"]["discussions"] = len(discussions["nodes"])
        if '"hasNextPage": true' in json.dumps(discussions):
            limitation("discussions", "nested pagination required")
    except Exception as exc:
        limitation("discussions", exc)
    text = "\n".join(p.read_text() for p in meta.glob("*.json"))
    attachments = sorted(set(re.findall(r"https://github\.com/user-attachments/(?:assets|files)/[^\s\"<>\\]+", text)))
    details["uninspected_issue_attachment_urls"] = attachments
    summary["issue_attachment_urls_not_downloaded"] = len(attachments)
    return collections["workflow_runs"], collections["workflow_artifacts"], collections["releases"]


def unpack_logs(blob: bytes, destination: Path) -> tuple[int, int]:
    """ZIP内の名前やsymlinkを信用せず、平坦なファイル名で書き出す。"""
    destination.mkdir(parents=True, exist_ok=True)
    size = 0
    count = 0
    with zipfile.ZipFile(io.BytesIO(blob)) as archive:
        members = [item for item in archive.infolist() if not item.is_dir()]
        if sum(item.file_size for item in members) > MAX_ARCHIVE:
            raise ValueError("uncompressed archive limit")
        for idx, item in enumerate(members):
            if item.file_size > MAX_MEMBER:
                raise ValueError("uncompressed member limit")
            with archive.open(item) as stream:
                data = stream.read(MAX_MEMBER + 1)
            if len(data) > MAX_MEMBER:
                raise ValueError("member size limit")
            (destination / f"{idx:04d}.txt").write_bytes(data)
            size += len(data)
            count += 1
    return count, size


def collect_logs(runs: list) -> None:
    own_id = int(os.environ["GITHUB_RUN_ID"])
    targets = [(int(run["id"]), attempt) for run in runs if int(run["id"]) != own_id
               for attempt in range(1, int(run.get("run_attempt", 1)) + 1)]
    result = {"attempts_requested": len(targets), "attempts_downloaded": 0, "files": 0, "bytes": 0}
    def get_one(target):
        run_id, attempt = target
        try:
            blob = request(API + f"/actions/runs/{run_id}/attempts/{attempt}/logs")
            return target, blob, None
        except Exception as exc:
            return target, None, exc
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        for target, blob, error in executor.map(get_one, targets):
            label = f"workflow_run_{target[0]}_attempt_{target[1]}"
            if error is not None:
                limitation(label, error)
                continue
            if result["bytes"] >= MAX_TOTAL_LOGS:
                limitation(label, "total uncompressed log limit")
                continue
            try:
                count, size = unpack_logs(blob, ROOT / "ci_logs" / label)
                result["attempts_downloaded"] += 1
                result["files"] += count
                result["bytes"] += size
            except Exception as exc:
                limitation(label, exc)
    summary["ci_logs"] = result


def collect_assets(artifacts: list, releases: list) -> None:
    dest = ROOT / "assets"
    dest.mkdir(exist_ok=True)
    records = []
    for item in artifacts:
        records.append((f"artifact_{item['id']}", item["archive_download_url"], item.get("size_in_bytes", 0), item.get("expired", False)))
    for release in releases:
        for item in release.get("assets", []):
            records.append((f"release_asset_{item['id']}", item["browser_download_url"], item.get("size", 0), False))
    downloaded = 0
    for label, url, size, expired in records:
        if expired or size > MAX_DOWNLOAD:
            limitation(label, "expired or download size limit")
            continue
        if not (url.startswith(API + "/actions/artifacts/") or url.startswith("https://github.com/" + REPO + "/releases/download/")):
            limitation(label, "unexpected download source")
            continue
        try:
            (dest / (label + ".bin")).write_bytes(request(url))
            downloaded += 1
        except Exception as exc:
            limitation(label, exc)
    summary["downloadable_assets"] = {"listed": len(records), "downloaded": downloaded}


def main() -> None:
    mirror = ROOT / "repository.git"
    command(["git", "clone", "--mirror", "https://github.com/" + REPO + ".git", str(mirror)])
    command(["git", "-C", str(mirror), "fetch", "origin", "+refs/pull/*:refs/pull/*"])
    def git(*args: str) -> bytes:
        return command(["git", "-C", str(mirror), *args])
    main_sha = git("rev-parse", "refs/heads/main").decode().strip()
    refs = git("for-each-ref", "--format=%(refname)").decode().splitlines()
    summary["main_sha"] = main_sha
    summary["git_reachable_commits"] = int(git("rev-list", "--all", "--count"))
    summary["git_refs"] = {"heads": sum(r.startswith("refs/heads/") for r in refs), "tags": sum(r.startswith("refs/tags/") for r in refs), "pull_refs": sum(r.startswith("refs/pull/") for r in refs)}
    details["refs"] = refs
    blob_dir = ROOT / "git_blobs"
    blob_dir.mkdir(exist_ok=True)
    object_paths = {}
    for line in git("rev-list", "--objects", "--all").decode().splitlines():
        oid, _, path = line.partition(" ")
        object_paths[oid] = path
    blob_count = blob_bytes = lfs_count = 0
    key_patterns = {
        "private_key_header": re.compile(rb"-----BEGIN (?:RSA |EC |DSA |OPENSSH |ENCRYPTED )?PRIVATE KEY-----"),
        "google_api_key_shape": re.compile(rb"AIza[0-9A-Za-z_-]{35}"),
        "github_token_shape": re.compile(rb"(?:gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{50,})"),
        "aws_access_id_shape": re.compile(rb"(?:AKIA|ASIA)[A-Z0-9]{16}"),
        "slack_token_shape": re.compile(rb"xox[baprs]-[A-Za-z0-9-]{20,}"),
        "stripe_secret_shape": re.compile(rb"(?:sk|rk)_(?:live|test)_[A-Za-z0-9]{16,}"),
    }
    with subprocess.Popen(["git", "-C", str(mirror), "cat-file", "--batch"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL) as proc:
        for oid, path in object_paths.items():
            proc.stdin.write((oid + "\n").encode())
            proc.stdin.flush()
            header = proc.stdout.readline().decode().strip().split()
            if len(header) != 3:
                raise ValueError("invalid Git object header")
            size = int(header[2])
            content = proc.stdout.read(size)
            if len(content) != size or proc.stdout.read(1) != b"\n":
                raise ValueError("incomplete Git object")
            if header[1] != "blob":
                continue
            (blob_dir / (oid + ".txt")).write_bytes(content)
            blob_count += 1
            blob_bytes += size
            lfs_count += content.startswith(b"version https://git-lfs.github.com/spec/v1")
            for name, pattern in key_patterns.items():
                match = pattern.search(content)
                if match:
                    details["supplemental_matches"].append({"rule": name, "blob": oid, "path": path, "line": content[:match.start()].count(b"\n") + 1})
        proc.stdin.close()
        proc.wait(timeout=30)
    summary["git_blobs"] = {"count": blob_count, "bytes": blob_bytes, "lfs_pointers_not_resolved": lfs_count}
    if lfs_count:
        limitation("git_lfs", "external LFS objects not downloaded")
    snapshot = ROOT / "snapshot"
    snapshot.mkdir(exist_ok=True)
    current_paths = []
    for row in git("ls-tree", "-rz", "--full-tree", main_sha).split(b"\0"):
        if not row:
            continue
        header, name = row.split(b"\t", 1)
        mode, kind, oid = header.decode().split()
        name = name.decode("utf-8")
        current_paths.append(name)
        path = PurePosixPath(name)
        if path.is_absolute() or ".." in path.parts:
            raise ValueError("unsafe Git path")
        if kind != "blob":
            limitation("snapshot_gitlink", "submodule not downloaded")
            continue
        target = snapshot.joinpath(*path.parts)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes((blob_dir / (oid + ".txt")).read_bytes())
    summary["current_tracked_paths"] = len(current_paths)
    risky = re.compile(r"(^|/)(\.env(?:\..*)?|google-services\.json|GoogleService-Info\.plist|[^/]*(?:service[-_]?account|credentials)[^/]*\.(?:json|ya?ml)|[^/]*\.(?:pem|p8|p12|pfx|jks|keystore)|id_(?:rsa|ed25519)|firepit-log\.txt)$", re.IGNORECASE)
    details["suspicious_current_filenames"] = [p for p in current_paths if risky.search(p)]
    details["suspicious_historical_filenames"] = sorted({p for p in object_paths.values() if p and risky.search(p)})
    metadata = ROOT / "metadata"
    metadata.mkdir(exist_ok=True)
    (metadata / "commit_messages.txt").write_bytes(git("log", "--all", "--format=fuller"))
    (metadata / "annotated_tags.txt").write_bytes(git("for-each-ref", "--format=%(refname)%0a%(taggername) %(taggeremail)%0a%(contents)", "refs/tags"))
    details["commit_identities"] = sorted(set(git("log", "--all", "--format=%aN <%aE>%n%cN <%cE>").decode().splitlines()))
    runs, artifacts, releases = collect_metadata()
    collect_logs(runs)
    collect_assets(artifacts, releases)
    binary_data = request(BINARY_URL)
    if hashlib.sha256(binary_data).hexdigest() != BINARY_SHA256:
        raise ValueError("scanner checksum mismatch")
    scanner = ROOT / "gitleaks"
    with tarfile.open(fileobj=io.BytesIO(binary_data), mode="r:gz") as archive:
        member = archive.getmember("gitleaks")
        if not member.isfile():
            raise ValueError("unexpected scanner member")
        scanner.write_bytes(archive.extractfile(member).read())
    scanner.chmod(0o700)
    summary["gitleaks_version"] = command([str(scanner), "version"]).decode().strip()
    config = ROOT / "default-config.toml"
    config.write_text("[extend]\nuseDefault = true\n")
    ignore = ROOT / "empty-ignore"
    ignore.write_text("")
    summary["scans"] = {}
    for scope, mode, directory in [("current_snapshot", "dir", snapshot), ("git_history", "git", mirror), ("all_git_blobs", "dir", blob_dir), ("github_and_git_metadata", "dir", metadata), ("actions_logs", "dir", ROOT / "ci_logs"), ("release_and_actions_assets", "dir", ROOT / "assets")]:
        directory.mkdir(exist_ok=True)
        report = ROOT / (scope + "-findings.json")
        args = [str(scanner), mode, str(directory), "--config", str(config), "--gitleaks-ignore-path", str(ignore), "--ignore-gitleaks-allow", "--redact=100", "--no-banner", "--log-level=error", "--exit-code=10", "--report-format=json", "--report-path", str(report), "--max-decode-depth=2", "--max-archive-depth=3"]
        if mode == "git":
            args += ["--log-opts=--all --full-history -m"]
        with (ROOT / (scope + "-scanner.log")).open("wb") as logfile:
            completed = subprocess.run(args, stdout=logfile, stderr=subprocess.STDOUT, timeout=300)
        findings = json.loads(report.read_text()) if report.exists() else []
        if completed.returncode not in (0, 10):
            limitation(scope, "scanner execution error")
        safe_findings = [{key: item.get(key) for key in ("RuleID", "Description", "File", "StartLine", "EndLine", "Commit", "Entropy")} for item in findings]
        if scope == "all_git_blobs":
            for item in safe_findings:
                oid = Path(item["File"]).stem
                item["git_path_hint"] = object_paths.get(oid)
        details["findings"][scope] = safe_findings
        summary["scans"][scope] = {"exit_code": completed.returncode, "findings": len(findings), "successfully_executed": completed.returncode in (0, 10)}
    summary["supplemental_matches"] = len(details["supplemental_matches"])
    summary["suspicious_current_filenames"] = len(details["suspicious_current_filenames"])
    summary["suspicious_historical_filenames"] = len(details["suspicious_historical_filenames"])
    summary["finished_utc"] = dt.datetime.now(dt.timezone.utc).isoformat()


try:
    main()
except Exception as exc:
    limitation("audit_execution", exc)
finally:
    summary["limitations"] = len(details["limitations"])
    public_json = json.dumps(summary, ensure_ascii=False, separators=(",", ":"))
    print("AUDIT_SUMMARY=" + public_json, flush=True)
    # 候補の場所や個人メールも公開ログへ出さず、一度限りの受信者証明書で暗号化する。
    report = ROOT / "private-report.json"
    save_json(report, {"summary": summary, "details": details})
    certificate = ROOT / "recipient-certificate.pem"
    certificate.write_text(CERTIFICATE)
    encrypted = command(["openssl", "cms", "-encrypt", "-aes256", "-binary", "-in", str(report), "-outform", "DER", str(certificate)])
    print("AUDIT_ENCRYPTED_REPORT=" + base64.b64encode(encrypted).decode(), flush=True)
    if details["limitations"] or any(s["findings"] for s in summary.get("scans", {}).values()) or details["supplemental_matches"]:
        raise SystemExit(1)
