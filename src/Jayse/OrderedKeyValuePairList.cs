using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Immutable;

#pragma warning disable CA1851 // Possible multiple enumerations of 'IEnumerable' collection


namespace Jayse
{
    public class OrderedImmutableDictionary
        <TKey, TValue> :
        IReadOnlyList<KeyValuePair<TKey, TValue>>,
        IReadOnlyDictionary<TKey, TValue>
        where TKey : notnull
    {
        private readonly ImmutableList<KeyValuePair<TKey, TValue>> kvpList;
        private readonly ImmutableDictionary<TKey, TValue> kvpDictionary;

        public OrderedImmutableDictionary(IEnumerable<KeyValuePair<TKey, TValue>> kvps)
        {
            kvpList = kvps.ToImmutableList();
            kvpDictionary = kvps.ToImmutableDictionary(pair => pair.Key, pair => pair.Value);
        }

        public IEnumerator<KeyValuePair<TKey, TValue>> GetEnumerator() => kvpList.GetEnumerator();
        IEnumerator IEnumerable.GetEnumerator() => kvpList.GetEnumerator();
        public bool ContainsKey(TKey key) => kvpDictionary.ContainsKey(key);


        public bool TryGetValue(TKey key, out TValue value)
        {
            var returnValue = kvpDictionary.TryGetValue(key, out var valueFromDictionary);

            if (valueFromDictionary == null) throw new InvalidOperationException();

            value = valueFromDictionary;
            return returnValue;
        }

        public int Count => kvpList.Count;
        public IEnumerable<TKey> Keys => kvpDictionary.Keys;
        public IEnumerable<TValue> Values => kvpDictionary.Values;
        public KeyValuePair<TKey, TValue> this[int index] => kvpList[index];
        public TValue this[TKey key] => kvpDictionary[key];
    }
}
