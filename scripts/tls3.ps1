Configuration tls3
{
    ######### BASELINES FOR SECURITY ON SERVERS AND WORKSTATIONS #########

    ### 1 - DISABLE INSECURE AND OBSOLETE PROTOCOLS ###

    # Protocol TLS1.0 on client side
    Registry DisableDeprecatedProtocolTLS1Client
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\TLS 1.0\Client"
        ValueName = "DisabledByDefault"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # Protocol TLS1.0 on server side
    Registry DisableDeprecatedProtocolTLS1Server
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\TLS 1.0\Server"
        ValueName = "DisabledByDefault"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # Protocol TLS1.1 on client side
    Registry DisableDeprecatedProtocolTLS1.1Client
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\TLS 1.1\Client"
        ValueName = "DisabledByDefault"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # Protocol TLS1.1 on server side
    Registry DisableDeprecatedProtocolTLS1.1Server
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\TLS 1.1\Server"
        ValueName = "DisabledByDefault"
        ValueType = "DWORD"
        ValueData = "1"
    }

    ### 2 - ENABLE AND FORCE USE OF TLS 1.2 ###

    # Enable TLS 1.2 on client side
    Registry EnableTLS1.2Client
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\TLS 1.2\Client"
        ValueName = "Enabled"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # Enable TLS 1.2 on server side
    Registry EnableTLS1.2Server
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\Schannel\Protocols\TLS 1.2\Server"
        ValueName = "Enabled"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # Force the use of TLS 1.2 in .NET applications
    Registry ForceUseOfTLS1.2Protocol
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
        ValueName = "SchUseStrongCrypto"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # Force the use of TLS 1.2 in .NET applications for 64-bit
    Registry ForceUseOfTLS1.2Protocol64
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319"
        ValueName = "SchUseStrongCrypto"
        ValueType = "DWORD"
        ValueData = "1"
    }

    # System-wide settings to prefer TLS 1.2 and disable others
    Registry SystemWideUseTLS1.2
    {
        Ensure    = "Present"
        Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
        ValueName = "DefaultSecureProtocols"
        ValueType = "DWORD"
        ValueData = "2560" # Decimal equivalent of 0x00000A00 (TLS 1.1 and 1.2 enabled)
    }
}
