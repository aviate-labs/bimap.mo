import BiMap "BiMap";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";

module {
    // Creates an empty map generator function.
    public func empty<L, R>(
        initCapacity : Nat,
        equal : (L, L) -> Bool,
        hash  : L -> Hash.Hash,
    ) : () -> BiMap.Map<L, R> {
        func () : BiMap.Map<L, R> {
            HashMap.HashMap<L, R>(initCapacity, equal, hash);
        };
    };
};
