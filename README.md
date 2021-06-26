# Jayse

Traverse and modify JSON documents with .NET records

![diagram](https://github.com/MelbourneDeveloper/Jayse/blob/main/Images/IconSmall.png) 

## What Is It And Why?
Sometimes you need to traverse or modify a JSON document without serialization or deserialization. Jayse represents JSON as a simple object model with one record and one enum. The existing libraries like JSON.Net don't do this very well and can be clunky to traverse. For example, inspecting a JSON tree with Json.Net involves `JObject`, `JToken`, `JProperty`, `JArray` and so on. Jayse makes it easy to traverse the JSON document tree and locate values. Take this JSON as an example:

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

```cs
//Convert JSON to the object model
var jsonObject = File.ReadAllText("TestData.json").ToJsonObject();

//Access the value in the ID property
Console.WriteLine(jsonObject["features"][0]["properties"]["ID"].AsGuid().ToString());
```

Output:

> 72cdd9ee-b48d-41af-b6b4-63df02eb7e18

## Build a JSON Model

This code creates a JSON object using the builder pattern and then converts it to formatted JSON.

```cs
public void PrintSomeJson()
{
    const string numberKey = "key3";
    const decimal numberValue = 3;
    const string stringValue = "value1";
    const string stringKey = "key1";
    const string boolKey = "key2";
    const string arrayKey = "4";
    const string innerKey = "innerkey";
    const string innerValue = "innervalue";

    //Create an array of numbers
    var expectedNumbers = new decimal[] { 1, 2, 3 };
    var jsonArray = expectedNumbers.ToJsonArray();

    //Stick an object in the array
    var innerObject =
        new JsonValue(innerValue)
        .ToJsonObject(innerKey)
        .ToJsonValue();
    jsonArray = jsonArray.Add(innerObject);

    //Create an object with a builder
    var jsonObject =
        stringValue.
        ToBuilder(stringKey).
        Add(boolKey, true).
        Add(numberKey, numberValue).
        Add(arrayKey, jsonArray).
        Build();

    //Print the formatted JSON
    var json = jsonObject.ToJson(true);
    Console.WriteLine(json);
}
```

Output:

```JSON
{
    "key1" : "value1",
    "key2" : true,
    "key3" : 3,
    "4" : 
    [
        1,
        2,
        3,
        
        {
            "innerkey" : "innervalue"
        }
    ]
}
```

## Design

The object model is easy to inspect. Each node contains a value of string, bool, array, object, number or null exactly like  the [JSON spec](https://www.json.org/json-en.html). All nodes are immutable records. You can use [non-destructive mutation](https://docs.microsoft.com/en-us/dotnet/csharp/whats-new/tutorials/records#non-destructive-mutation) to modify values. For example, if you wanted to modify the ID property, you can create a new properties node like so:

```cs
//Convert JSON to the object model
var jsonObject = File.ReadAllText("TestData.json").ToJsonObject();

var features = jsonObject["features"];
var firstFeature = features.ArrayValue.First();
//Get the properties node
var properties = firstFeature.ObjectValue["properties"].ObjectValue;

//Create a new properties node with the value of "newid" as the ID property
var properties2 = properties.With("ID", new JsonValue("newid"));
```
