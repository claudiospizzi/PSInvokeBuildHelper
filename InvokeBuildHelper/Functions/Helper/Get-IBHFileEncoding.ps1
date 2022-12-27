<#
    .SYNOPSIS
        Guess the encoding of the specified file.

    .DESCRIPTION
        First we read the first 4 bytes of a file

    .OUTPUTS
        System.Text.Encoding. Encoding of the file.

    .EXAMPLE
        PS C:\> Get-IBHFileEncoding -Path 'C:\Temp\demo.txt'
        Guess the encoding of the demo.txt file.

    .LINK
        https://github.com/claudiospizzi/InvokeBuildHelper
#>
function Get-IBHFileEncoding
{
    [CmdletBinding()]
    [OutputType([System.Text.Encoding])]
    param
    (
        # Path to the file.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    # Read the first 4 bytes of the file.
    if ($PSVersionTable.PSVersion.Major -lt 6)
    {
        [System.Byte[]] $bytes = Get-Content -Path $Path -TotalCount 4 -Encoding 'Byte'
    }
    else
    {
        [System.Byte[]] $bytes = Get-Content -Path $Path -TotalCount 4 -AsByteStream
    }

    # Binary
    # Read the first 5 lines of the file and check them for non printable
    # charactres. If we find any, it's a binary file.
    $nonPrintable = [System.Char[]] (0..8 + 10..31 + 127 + 129 + 141 + 143 + 144 + 157)
    $affectedLineCount = Get-Content -Path $Path -TotalCount 5 |
                             Where-Object { $_.IndexOfAny($nonPrintable) -ne -1 } |
                                 Measure-Object | Select-Object -ExpandProperty 'Count'
    if ($affectedLineCount -gt 0)
    {
        throw 'Binary files have no encoding!'
    }

    # UTF8 (EF BB BF)
    if ($bytes.Length -ge 3 -and
        $bytes[0] -eq 0xef -and
        $bytes[1] -eq 0xbb -and
        $bytes[2] -eq 0xbf)
    {
        return [System.Text.Encoding]::UTF8
    }

    # UTF16 Big-Endian (FE FF)
    if ($bytes.Length -ge 2 -and
        $bytes[0] -eq 0xfe -and
        $bytes[1] -eq 0xff)
    {
        return [System.Text.Encoding]::BigEndianUnicode
    }

    # UTF16 Little-Endian (FF FE)
    if ($bytes.Length -ge 2 -and
        $bytes[0] -eq 0xff -and
        $bytes[1] -eq 0xfe)
    {
        return [System.Text.Encoding]::Unicode
    }

    # UTF32 Big-Endian (00 00 FE FF)
    if ($bytes.Length -ge 4 -and
        $bytes[0] -eq 0x00 -and
        $bytes[1] -eq 0x00 -and
        $bytes[2] -eq 0xfe -and
        $bytes[3] -eq 0xff)
    {
        return [System.Text.Encoding]::UTF32
    }

    # UTF32 Little-Endian (FE FF 00 00)
    if ($bytes.Length -ge 4 -and
        $bytes[0] -eq 0xfe -and
        $bytes[1] -eq 0xff -and
        $bytes[2] -eq 0x00 -and
        $bytes[3] -eq 0x00)
    {
        return [System.Text.Encoding]::UTF32
    }

    # UTF7 (2B 2F 76 38|38|2B|2F)
    if ($bytes.Length -ge 4 -and
        $bytes[0] -eq 0x2b -and
        $bytes[1] -eq 0x2f -and
        $bytes[2] -eq 0x76 -and
        ($bytes[3] -eq 0x38 -or $bytes[3] -eq 0x39 -or $bytes[3] -eq 0x2b -or $bytes[3] -eq 0x2f))
    {
        throw 'UTF7 is not a supported encoding!'
    }

    # UTF-1 (F7 64 4C)
    if ($bytes.Length -ge 3 -and
        $bytes[0] -eq 0xf7 -and
        $bytes[1] -eq 0x64 -and
        $bytes[2] -eq 0x4c )
    {
        throw 'UTF-1 is not a supported encoding!'
    }

    # UTF-EBCDIC (DD 73 66 73)
    if ($bytes.Length -ge 4 -and
        $bytes[0] -eq 0xdd -and
        $bytes[1] -eq 0x73 -and
        $bytes[2] -eq 0x66 -and
        $bytes[3] -eq 0x73)
    {
        throw 'UTF-EBCDIC is not a supported encoding!'
    }

    # SCSU (0E FE FF)
    if ($bytes.Length -ge 3 -and
        $bytes[0] -eq 0x0e -and
        $bytes[1] -eq 0xfe -and
        $bytes[2] -eq 0xff)
    {
        throw 'SCSU is not a supported encoding!'
    }

    # BOCU-1 (FB EE 28)
    if ($bytes.Length -ge 3 -and
        $bytes[0] -eq 0xfb -and
        $bytes[1] -eq 0xee -and
        $bytes[2] -eq 0x28 )
    {
        throw 'BOCU-1 is not a supported encoding!'
    }

    # GB-18030 (84 31 95 33)
    if ($bytes.Length -ge 4 -and
        $bytes[0] -eq 0x84 -and
        $bytes[1] -eq 0x31 -and
        $bytes[2] -eq 0x95 -and
        $bytes[3] -eq 0x33)
    {
        throw 'GB-18030 is not a supported encoding!'
    }

    # If the function will reach this point, the encoding was NOT found by
    # parsing the BOM header. Starting from here, we are guessing based on the
    # file content.

    # We are checking, if any byte has a value greather than 127, this indicates
    # it's a UTF8 encoded file.
    if ($bytes -notmatch '^[\x00-\x7F]*$')
    {
        return [System.Text.Encoding]::UTF8
    }
    else
    {
        return [System.Text.Encoding]::ASCII
    }
}
