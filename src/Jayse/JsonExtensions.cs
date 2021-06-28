using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Text;

#pragma warning disable format
#pragma warning disable CS8600 // Converting null literal or possible null value to non-nullable type.
#pragma warning disable CS8604 // Possible null reference argument.
#pragma warning disable CA1305 // Specify IFormatProvider
#pragma warning disable IDE0057 // Use range operator

namespace Jayse
{


    public static class JsonExtensions
    {
        internal const string TabText= "    ";
        internal static string CrLf(bool format) => format?"\r\n":"";

        internal static string RepeatTab(bool format, int depth) => format? TabText.Repeat(depth):"";

        private static string Repeat(this string text, int times)
        {
            var sb = new StringBuilder();
            for (var i = 0; i < times; i++)
            {
                _ = sb.Append(text);
            }
            return sb.ToString();
        }

#if !NETSTANDARD2_0
        public static OrderedImmutableDictionary<string, JsonValue> With(this OrderedImmutableDictionary<string, JsonValue> jsonObject, string key, JsonValue value)
        => new(new Dictionary<string, JsonValue>(jsonObject)
            {
                [key] = value
            });
#endif


        public static string ToJson(this IReadOnlyDictionary<string, JsonValue> jsonObject, bool format = false, int depth = 1) =>
            RepeatTab(format,depth - 1) + "{" + CrLf(format) + 
            string.Join($",{CrLf(format)}", jsonObject.Select(kvp => $"{RepeatTab(format,depth)}\"{kvp.Key}\" : {kvp.Value.ToJson(format, depth)}")) + CrLf(format) + 
            RepeatTab(format,depth - 1) + "}";

        public static Guid AsGuid(this JsonValue jsonValue) 
        => jsonValue==null?throw new InvalidOperationException(): new(jsonValue.StringValue);

        public static OrderedImmutableDictionary<string, JsonValue> ToJsonObject(this string json)
        {

            var deserializedObject = (JObject)JsonConvert.DeserializeObject(json);

            return ProcessObject(deserializedObject);

        }

        private static OrderedImmutableDictionary<string, JsonValue> ProcessObject(JObject deserializedObject)
        {
            var jsonObject = new Dictionary<string, JsonValue>();

            foreach (var property in deserializedObject.Properties())
            {
                ProcessProperty(jsonObject, property);
            }

            return new OrderedImmutableDictionary<string, JsonValue>( jsonObject);
        }

        private static void ProcessProperty(Dictionary<string, JsonValue> jsonObject, JProperty property)
        {
            switch (property.Value.Type)
            {
                case JTokenType.String:
                    jsonObject.Add(property.Name, new JsonValue((string)property.Value));
                    break;
                case JTokenType.None:
                    throw new NotImplementedException();
                case JTokenType.Object:
                    jsonObject.Add(property.Name, new JsonValue(ProcessObject((JObject)property.Value)));
                    break;
                case JTokenType.Array:

                    var children = new List<JsonValue>();
                    foreach(var token in property.Value.Children())
                    {
                        if (token is JValue value)
                        {
                            children.Add(value.Value!=null? new JsonValue(value.Value<decimal>()): new JsonValue());
                        }
                        else
                        {
                            var childJsonObject = new Dictionary<string, JsonValue>();

                            foreach (JProperty childProperty in token.Children())
                            {
                                ProcessProperty(childJsonObject, childProperty);
                            }

                            children.Add(new JsonValue(new OrderedImmutableDictionary<string, JsonValue>(childJsonObject)));
                        }
                    }

                    jsonObject.Add(property.Name, new JsonValue(children.ToImmutableList()));

                    break;
                case JTokenType.Integer:
                    jsonObject.Add(property.Name, new JsonValue((int)property.Value));
                    break;
                case JTokenType.Null:
                    jsonObject.Add(property.Name, new JsonValue());
                    break;
                case JTokenType.Date:
                    jsonObject.Add(property.Name, new JsonValue(((DateTime)property.Value).ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'fff'Z'")));
                    break;
                case JTokenType.Boolean:
                    jsonObject.Add(property.Name, new JsonValue((bool)property.Value));
                    break;
                case JTokenType.Constructor:
                case JTokenType.Property:
                case JTokenType.Comment:
                case JTokenType.Float:
                case JTokenType.Undefined:
                case JTokenType.Raw:
                case JTokenType.Bytes:
                case JTokenType.Guid:
                case JTokenType.Uri:
                case JTokenType.TimeSpan:
                default:
                    throw new NotImplementedException();
            }
        }

        public static OrderedImmutableDictionary<string, JsonValue> ToJsonObject(this JsonValue jsonValue, string key)
        => new(new List<KeyValuePair<string, JsonValue>>
        {
            new(key, jsonValue )
        });

        public static OrderedImmutableDictionary<string, JsonValue> ToJsonObject(this IEnumerable<KeyValuePair<string, JsonValue>> jsonValues)
        => new(jsonValues);

        public static JsonValue ToJsonValue(this string stringValue)
        => new(stringValue);

        public static JsonValue ToJsonValue(this bool booleanValue)
        => new(booleanValue);

        public static JsonValue ToJsonValue(this decimal numberValue)
        => new(numberValue);

        public static JsonValue ToJsonValue(this ImmutableList<JsonValue> arrayValue)
        => new(arrayValue);

        public static JsonValue ToJsonValue(this OrderedImmutableDictionary<string, JsonValue> jsonObject)
        => new(jsonObject);

        public static JsonValueBuilder Add(this JsonValueBuilder jsonValueBuilder, string key, string stringValue) 
            => jsonValueBuilder==null?throw new ArgumentNullException(nameof(jsonValueBuilder)) : 
            jsonValueBuilder.Add(key, stringValue.ToJsonValue());

        public static JsonValueBuilder Add(this JsonValueBuilder jsonValueBuilder, string key, bool booleanValue)
            => jsonValueBuilder == null ? throw new ArgumentNullException(nameof(jsonValueBuilder)) :
            jsonValueBuilder.Add(key, booleanValue.ToJsonValue());

        public static JsonValueBuilder Add(this JsonValueBuilder jsonValueBuilder, string key, decimal numberValue)
            => jsonValueBuilder == null ? throw new ArgumentNullException(nameof(jsonValueBuilder)) :
            jsonValueBuilder.Add(key, numberValue.ToJsonValue());

        public static JsonValueBuilder Add(this JsonValueBuilder jsonValueBuilder, string key, ImmutableList<JsonValue> arrayValue)
            => jsonValueBuilder == null ? throw new ArgumentNullException(nameof(jsonValueBuilder)) :
            jsonValueBuilder.Add(key, arrayValue.ToJsonValue());

        public static JsonValueBuilder ToBuilder(this JsonValue jsonValue, string key) 
            => new JsonValueBuilder().Add(key, jsonValue);

        public static JsonValueBuilder ToBuilder(this string stringValue, string key)
            => new JsonValueBuilder().Add(key, new(stringValue));

        public static JsonValueBuilder ToBuilder(this bool booleanValue, string key)
            => new JsonValueBuilder().Add(key, new(booleanValue));

        public static JsonValueBuilder ToBuilder(this decimal numberValue, string key)
            => new JsonValueBuilder().Add(key, new(numberValue));

        public static JsonValueBuilder ToBuilder(this ImmutableList<JsonValue> arrayValue, string key)
            => new JsonValueBuilder().Add(key, new(arrayValue));


        public static ImmutableList<JsonValue> ToJsonArray(this IEnumerable<string> stringValues) 
            => stringValues == null? throw new ArgumentNullException(nameof(stringValues)):
            stringValues.Select(s => new JsonValue(s)).ToImmutableList();


        public static ImmutableList<JsonValue> ToJsonArray(this IEnumerable<bool> booleanValues)
            => booleanValues == null ? throw new ArgumentNullException(nameof(booleanValues)) :
            booleanValues.Select(s => new JsonValue(s)).ToImmutableList();

        public static ImmutableList<JsonValue> ToJsonArray(this IEnumerable<decimal> numberValues)
            => numberValues == null ? throw new ArgumentNullException(nameof(numberValues)) :
            numberValues.Select(s => new JsonValue(s)).ToImmutableList();

#if !NETSTANDARD2_0

        public static OrderedImmutableDictionary<string, JsonValue> Parse(this string json)
        {
            var keyValuePairs = new List<KeyValuePair< string, JsonValue>>();
            var trimmedText = json.Trim();
            if(trimmedText.First()!='{' || trimmedText.Last()!='}') throw new InvalidOperationException("Nah");
            var innerJson = trimmedText.Substring(1, trimmedText.Length - 2);

            var rows = innerJson.Split(new char[] { ',' });
            foreach(var row in rows)
            {
                var tokens = row.Split(':', 2).Select(s => s.Trim()).ToList(); ;

                if(tokens.Count!=2)
                {
                    throw new InvalidOperationException("Nah");
                }

                var keyName = tokens[0].Replace("\"", "", StringComparison.OrdinalIgnoreCase);

                if(tokens[1][0]=='\"')
                {
                    keyValuePairs.Add(new KeyValuePair<string, JsonValue>( keyName, new JsonValue(tokens[1].Replace("\"", "", StringComparison.OrdinalIgnoreCase))));
                }

            }

            return new OrderedImmutableDictionary<string, JsonValue>( keyValuePairs);
        }
#endif

    }


}

