dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", "https://github.com/causefx/Organizr/archive/v2-master.zip", False
xHttp.Send

with bStrm
    .type = 1 '//binary
    .open
    .write xHttp.responseBody
    .savetofile "Organizr-2-master.zip", 2 '//overwrite
end with