import std.socket;
import std.stdio : stderr, writeln;

void usage(string program)
{
    writeln("OffensiveD DNS Lookup");
    writeln();
    writeln("Usage:");
    writeln("  ", program, " <hostname>");
    writeln();
    writeln("Example:");
    writeln("  ", program, " example.com");
}

void main(string[] args)
{
    if (args.length != 2)
    {
        usage(args[0]);
        return;
    }

    immutable string hostname = args[1];

    try
    {
        AddressInfo[] results = getAddressInfo(
            hostname,
            AddressInfoFlags.CANONNAME
        );

        if (results.length == 0)
        {
            stderr.writeln("[-] No addresses found for ", hostname);
            return;
        }

        writeln("[*] Host: ", hostname);

        if (results[0].canonicalName.length > 0)
            writeln("[*] Canonical name: ", results[0].canonicalName);

        writeln();

        size_t count;

        foreach (result; results)
        {
            string family;

            switch (result.family)
            {
                case AddressFamily.INET:
                    family = "IPv4";
                    break;

                case AddressFamily.INET6:
                    family = "IPv6";
                    break;

                default:
                    family = "Other";
                    break;
            }

            string address;

            auto ipv4 = cast(InternetAddress) result.address;
            if (ipv4 !is null)
            {
                address = ipv4.toAddrString();
            }
            else
            {
                auto ipv6 = cast(Internet6Address) result.address;

                if (ipv6 !is null)
                    address = ipv6.toAddrString();
                else
                    address = result.address.toString();
            }

            writeln("[+] ", family, ": ", address);
            ++count;
        }

        writeln();
        writeln("[*] Addresses returned: ", count);
    }
    catch (AddressException error)
    {
        stderr.writeln("[-] DNS lookup failed: ", error.msg);
    }
    catch (SocketOSException error)
    {
        stderr.writeln("[-] Socket error: ", error.msg);
    }
    catch (Exception error)
    {
        stderr.writeln("[-] Error: ", error.msg);
    }
}