dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "http://nginx.org/download/nginx-1.14.0.zip", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile "nginx.zip", 2 '//overwrite
end with