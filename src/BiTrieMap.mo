import Hash "mo:base/Hash";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";
import Result "mo:base/Result";

module self {
    public class BiTrieMap<L, R> (
        leftEqual    : (L, L) -> Bool,
        leftHash     : L -> Hash.Hash,
        rightEqual   : (R, R) -> Bool,
        rightHash    : R -> Hash.Hash,
    ) {
        var leftToRight = TrieMap.TrieMap<L, R>(
            leftEqual, leftHash,
        );
        var rightToLeft = TrieMap.TrieMap<R, L>(
            rightEqual, rightHash,
        );

        // Returns the number of pairs in the bimap.
        public func size() : Nat {
            leftToRight.size();
        };

        // Returns whether the bimap contains no pairs.
        public func isEmpty() : Bool {
            size() == 0;
        };

        // Removes all pairs from the bimap.
        public func clear() {
            leftToRight := TrieMap.TrieMap<L, R>(leftEqual, leftHash);
            rightToLeft := TrieMap.TrieMap<R, L>(rightEqual, rightHash); 
        };

        // Creates an iterator over the left-right pairs in the bimap.
        public func entries() : Iter.Iter<(L, R)> {
            leftToRight.entries();
        };

        // Creates an iterator over the left values in the bimap.
        public func keys() : Iter.Iter<L> {
            Iter.map(leftToRight.entries(), func ((l, _) : (L, R)) : L { l; })
        };

        // Creates an iterator over the right values in the bimap.
        public func vals() : Iter.Iter<R> {
            Iter.map(leftToRight.entries(), func ((_, r) : (L, R)) : R { r; })
        };

        // Returns the right value corresponding to the given left value.
        public func getByLeft(key : L) : ?R {
            leftToRight.get(key);
        };

        // Returns the left value corresponding to the given right value.
        public func getByRight(key : R) : ?L {
            rightToLeft.get(key);
        };

        // Returns whether the bimap contains the given left value.
        public func containsLeft(key : L) : Bool {
            switch (getByLeft(key)) {
                case (null) { false; };
                case (? l)  { true;  };
            };
        };

        // Returns whether the bimap contains the given right value.
        public func containsRight(key : R) : Bool {
            switch (getByRight(key)) {
                case (null) { false; };
                case (? l)  { true;  };
            };
        };

        // Removes the left-right pair corresponding to the given left value.
        // Returns the previous left-right pair if the map contained the left value.
        public func removeByLeft(key : L) : ?(L, R) {
            switch (leftToRight.remove(key)) {
                case (null) { null; };
                case (?  r) {
                    ignore rightToLeft.remove(r);
                    ?(key, r);
                };
            };
        };

        // Removes the left-right pair corresponding to the given right value.
        // Returns the previous left-right pair if the map contained the right value.
        public func removeByRight(key : R) : ?(L, R) {
            switch (rightToLeft.remove(key)) {
                case (null) { null; };
                case (?  l) {
                    ignore leftToRight.remove(l);
                    ?(l, key);
                };
            };
        };

        type Overwritten<L, R> = {
            #Neither;
            #Right : (L, R);
            #Pair  : (L, R);
            #Left  : (L, R);
            #Both  : ((L, R), (L, R));
        };

        // Inserts the given left-right pair into the bimap.
        // Returns an enum representing any left-right pairs that were overwritten.
        public func replace(l : L, r : R) : Overwritten<L, R> {
            let o = switch (removeByLeft(l), removeByRight(r)) {
                case (null, null) {
                    #Neither;
                };
                case (null, ? rp) {
                    #Right(rp);
                };
                case (? lp, null) {
                    // Right got possibly removed by removeByLeft().
                    if (rightEqual(lp.1, r)) { #Pair(lp); }
                    else                     { #Left(lp); };
                };
                case (? lp, ? rp) {
                    #Both((lp, rp));
                };
            };
            _insert(l, r);
            o;
        };

        // Inserts the given left-right pair into the bimap without overwriting any existing values.
        public func insert(l : L, r : R) : Result.Result<(), (L, R)> {
            if (containsLeft(l) or containsRight(r)) {
                return #err((l, r));
            };
            _insert(l, r);
            #ok();
        };

        // Inserts the given left-right pair into the bimap without checking if the pair already exists.
        private func _insert(l : L, r : R) {
            leftToRight.put(l, r);
            rightToLeft.put(r, l);
        };

        // Retains only the elements specified by the predicate.
        // I.e. remove all values for which f returns false.
        public func retain(f : (L, R) -> Bool) {
            for ((l, r) in entries()) {
                if (not f(l, r)) {
                    ignore removeByLeft(l);
                };
            };
        };

        // Clones the current state to a new bimap.
        public func clone() : BiTrieMap<L, R> {
            self.fromIter<L, R>(
                entries(),
                leftEqual, leftHash,
                rightEqual, rightHash,
            );
        };
    };

    // Convert the given iterator into a new bimap.
    public func fromIter<L, R>(
        iter         : Iter.Iter<(L, R)>,
        leftEqual    : (L, L) -> Bool,
        leftHash     : L -> Hash.Hash,
        rightEqual   : (R, R) -> Bool,
        rightHash    : R -> Hash.Hash,
    ) : BiTrieMap<L, R> {
        let m = BiTrieMap<L, R>(
            leftEqual, leftHash,
            rightEqual, rightHash,
        );
        for ((l, r) in iter) {
            ignore m.replace(l, r);
        };
        m;
    };
};
