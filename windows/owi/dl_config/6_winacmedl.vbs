dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "https://github.com/PKISharp/win-acme/releases/download/v2.1.2.641/win-acme.v2.1.2.641.x64.pluggable.zip", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile "winacme.zip", 2 '//overwrite
end with
