import BiMap "BiMap";
import Hash "mo:base/Hash";
import TrieMap "mo:base/TrieMap";

module {
    // Creates an empty map generator function.
    public func empty<L, R>(
        equal : (L, L) -> Bool,
        hash  : L -> Hash.Hash,
    ) : () -> BiMap.Map<L, R> {
        func () : BiMap.Map<L, R> {
            TrieMap.TrieMap<L, R>(equal, hash);
        };
    };
};
