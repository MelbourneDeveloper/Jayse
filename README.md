# Jayse

Traverse and modify JSON documents with .NET records

![diagram](https://github.com/MelbourneDeveloper/Jayse/blob/main/Images/IconSmall.png) 

## What Is It And Why?
Sometimes you need to traverse or modify a JSON document without serialization or deserialization. Jayse represents JSON as a simple object model with one record and one enum. The existing libraries like JSON.Net don't do this very well and can be clunky to traverse. Jayse makes it easy to traverse the JSON document tree and locate values. Take this JSON as an example:

```JSON
{
    "type" : "FeatureCollection",
    "name" : "Water_Supply_Pumpset_Assets",
    "crs" : 
    {
        "type" : "name",
        "properties" : 
        {
            "name" : "urn:ogc:def:crs:OGC:1.3:CRS84"
        }
    },
    "stuff" : null,
    "features" : 
    [
        
        {
            "type" : "Feature",
            "properties" : 
            {
                "ID" : "72cdd9ee-b48d-41af-b6b4-63df02eb7e18",
                "OBJECTID" : 1,
                "MXUNITID" : "WP099P1P",
                "MXSITEID" : "MWS",
                "COMPKEY" : 53884,
                "ISBIG" : true,
                "INSTALLDATE" : "2009-02-15T00:00:00.000Z"
            },
            "geometry" : 
            {
                "type" : "Point",
                "coordinates" : 
                [
                    145.07016,
                    -37.64136
                ]
            }
        }
    ]
}
```

Let's say that we want to get the value of `ID` as a `Guid`. We can do that by accessing the value like so:

```
var jsonObject = File.ReadAllText("TestData.json").ToJsonObject();
Console.WriteLine(jsonObject["features"][0]["properties"]["ID"].AsGuid().ToString());
```

Output:

> 72cdd9ee-b48d-41af-b6b4-63df02eb7e18

