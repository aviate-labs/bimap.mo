import BiMap "BiMap";
import Hash "mo:base-0.7.3/Hash";
import HashMap "mo:base-0.7.3/HashMap";

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
