dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "https://raw.githubusercontent.com/rmbolger/Posh-ACME/master/Posh-ACME/DnsPlugins/Cloudflare.ps1", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile "cloudflare.ps1", 2 '//overwrite
end with