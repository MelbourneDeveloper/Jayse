using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.IO;
using System.Linq;

namespace Jayse.UnitTests
{


    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestToJsonValue()
        {
            const string stringValue = "stringValue";
            var jsonValue = stringValue.ToJsonValue();
            Assert.AreEqual(stringValue, jsonValue.StringValue);
        }

        [TestMethod]
        public void TestToJsonValue2()
        {
            var jsonValue = true.ToJsonValue();
            Assert.AreEqual(true, jsonValue.BooleanValue);
        }

        [TestMethod]
        public void TestCreateJsonObject()
        {
            const string key = "key";
            var jsonValue = new JsonValue("value");
            var dictionary = jsonValue.ToJsonObject(key);
            Assert.AreEqual(jsonValue, dictionary[key]);
        }

        [TestMethod]
        public void TestCreateJsonObject2()
        {
            const string key = "key";
            var jsonValue = "value".ToJsonValue();

            var dictionary =
                new List<KeyValuePair<string, JsonValue>>
                {
                    new(key, jsonValue),
                    new("key2", "value2".ToJsonValue())
                }
                .ToJsonObject();

            Assert.AreEqual(jsonValue, dictionary[key]);
        }

        [TestMethod]
        public void TestBuilder()
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

            //Get only the numbers from the array
            var actualNumbers =
                jsonObject[arrayKey].
                ArrayValue.Where(n => n.ValueType == JsonValueType.OfNumber).
                Select(n => n.NumberValue);

            //Asserts
            Assert.AreEqual(stringValue, jsonObject[stringKey].StringValue);
            Assert.AreEqual(true, jsonObject[boolKey].BooleanValue);
            Assert.AreEqual(numberValue, jsonObject[numberKey].NumberValue);
            Assert.AreEqual(innerValue, jsonObject[arrayKey][3][innerKey].StringValue);
            Assert.IsTrue(expectedNumbers.SequenceEqual(actualNumbers));

            //Print the formatted JSON
            var json = jsonObject.ToJson(true);
            Console.WriteLine(json);

            jsonObject = json.ToJsonObject();

            Assert.AreEqual(stringValue, jsonObject[stringKey].StringValue);
            Assert.AreEqual(true, jsonObject[boolKey].BooleanValue);
            Assert.AreEqual(numberValue, jsonObject[numberKey].NumberValue);
            Assert.AreEqual(innerValue, jsonObject[arrayKey][3][innerKey].StringValue);
            Assert.IsTrue(expectedNumbers.SequenceEqual(actualNumbers));
        }

        [TestMethod]
        public void TestNonDestructiveMutability()
        {
            var expectedJson = File.ReadAllText("TestDataMutated.json");
            var jsonObject = File.ReadAllText("TestData.json").ToJsonObject();

            var features = jsonObject["features"];

            var firstFeature = features.ArrayValue.First();

            var properties = firstFeature.ObjectValue["properties"].ObjectValue;

            var properties2 = properties.With("ID", new JsonValue("newid"));

            var firstFeature2 = firstFeature.ObjectValue.With("properties", new JsonValue(properties2));

            var jsonObject2 = jsonObject.With("features", new JsonValue(new List<JsonValue> { new JsonValue(firstFeature2) }.ToImmutableList()));

            var mutatedJson = jsonObject2.ToJson(true);

            Assert.AreEqual(expectedJson, mutatedJson);
        }

        [TestMethod]
        public void TestTheJsons()
        {
            var originalJson = File.ReadAllText("TestData.json");
            var jsonObject = originalJson.ToJsonObject();
            Assert.IsNotNull(jsonObject);

            Assert.AreEqual(5, jsonObject.Count);

            var features = jsonObject["features"];

            var properties = features.
                ArrayValue[0].
                ObjectValue["properties"];


            var geometry = features.
                            ArrayValue.First().
                            ObjectValue["geometry"];

            var coordinatesObject = geometry.ObjectValue["coordinates"];

            var coordinatesArray = coordinatesObject.ArrayValue;

            Assert.AreEqual(JsonValueType.OfNull, jsonObject["stuff"].ValueType);

            Assert.AreEqual(new Guid("72cdd9ee-b48d-41af-b6b4-63df02eb7e18"),
            jsonObject["features"][0]["properties"]["ID"].AsGuid());

            Assert.AreEqual("name",
                jsonObject["crs"]
                ["type"].
                StringValue);

            Assert.AreEqual(1,
                properties.
                ObjectValue["OBJECTID"].
                NumberValue);

            Assert.AreEqual(true,
                properties.
                ObjectValue["ISBIG"].
                BooleanValue);

            Assert.AreEqual("72cdd9ee-b48d-41af-b6b4-63df02eb7e18",
                properties.
                ObjectValue["ID"].
                StringValue);

            Assert.AreEqual("2009-02-15T00:00:00.000Z",
                properties.
                ObjectValue["INSTALLDATE"].
                StringValue);

            Assert.AreEqual((decimal)145.07016,
                coordinatesArray.First().NumberValue);

            Console.WriteLine(jsonObject.ToJson(false));
            Console.WriteLine();

            var formattedJson = jsonObject.ToJson(true);

            Assert.AreEqual(originalJson, formattedJson);

            Console.WriteLine(formattedJson);
        }
    }
}




