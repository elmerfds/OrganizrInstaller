dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "https://github.com/win-acme/win-acme/releases/download/v2.1.12/win-acme.v2.1.12.943.x64.pluggable.zip", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile "winacme.zip", 2 '//overwrite
end with
