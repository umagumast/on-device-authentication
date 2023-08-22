Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function

Function GetContentFeed()
    url = CreateObject("roUrlTransfer")
    url.SetUrl("https://dev.marvnationtv.com/tv-feed/roku-feed-v2.xml")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    rsp = url.GetToString()
    responseXML = ParseXML(rsp)
    if responseXML <> invalid then
        responseXML = responseXML.GetChildElements()
        responseArray = responseXML.GetChildElements()
    End if
    result = []
    for each xmlItem in responseArray
        if xmlItem.getName() = "item"
            itemAA = xmlItem.getChildElements()
            if itemAA <> invalid
                item = {}
                for each xmlItem in itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content"
                        item.stream = {url: xmlItem.url}
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = "hls"
                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterURL = mediaContentItem.getattributes().url
                                item.HDBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
                        end for
                    end if
                end for
                result.push(item)
            end if
        end if
    end for
    return result
End Function

Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    for each rowAA in list
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title
        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            item.setFields(itemAA)
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for
    return RowItems
End Function

Sub Init()
    m.top.functionName = "loadContent"
End Sub

Sub loadContent()
    oneRow = GetContentFeed()
    list = [
       {
           Title:"Live Channels"
           ContentList: SelectTo(oneRow, 2)
       },
       {
           Title:"Fights"
           ContentList: SelectTo(oneRow, 3, 2)
       },
       {
           Title:"Events"
           ContentList: SelectTo(oneRow, 3, 6)
       }
    ]
    m.top.content = ParseXMLContent(list)
End Sub

Function SelectTo(array as Object, num=25 as Integer, start=0 as Integer) as Object
    result = []
    for i = start to array.count()-1
        result.push(array[i])
        if result.Count() >= num
            exit for
        end if
    end for
    return result
End Function
