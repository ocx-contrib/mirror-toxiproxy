# tests/smoke.star — stable across upstream releases AND across all three
# variants. This one script runs against every variant bundle the pipeline
# builds:
#   default (full)  -> ships BOTH toxiproxy-cli + toxiproxy-server
#   client          -> ships toxiproxy-cli only
#   server          -> ships toxiproxy-server only
# The smoke API exposes no variant/identifier signal, ocx.exists/read_file only
# see the scratch root (not the bundle content root), and ocx.run aborts the
# whole script when argv[0] is missing — so we cannot probe a binary by running
# it. Instead gate each probe behind the platform's always-present locator
# (`command -v` via sh on unix, `where` on Windows), which resolves on the
# inherited system PATH and returns presence as an exit code.
WIN = ocx.target_platform.os == ocx.os.Windows
EXE = ".exe" if WIN else ""
CLI = "toxiproxy-cli" + EXE
SRV = "toxiproxy-server" + EXE

def on_path(name):
    if WIN:
        return ocx.run("where", name).exit_code == 0
    return ocx.run("sh", "-c", "command -v " + name).exit_code == 0

# Every variant bundle must carry at least one toxiproxy binary on PATH.
expect.true(on_path(CLI) or on_path(SRV))

def check_cli():
    if not on_path(CLI):
        return
    # Tier 1 + 2: liveness + version SHAPE (never vendor string / exact version).
    r = ocx.run(CLI, "--version")
    expect.ok(r)
    expect.matches(r.stdout, r"\d+\.\d+\.\d+")
    # Tier 3: subcommand surface exists — exit-code probe, not help prose.
    expect.eq(ocx.run(CLI, "help", "list").exit_code, 0)

def check_server():
    if not on_path(SRV):
        return
    # Tier 1 + 2: liveness + version SHAPE.
    r = ocx.run(SRV, "--version")
    expect.ok(r)
    expect.matches(r.stdout, r"\d+\.\d+\.\d+")

check_cli()
check_server()
