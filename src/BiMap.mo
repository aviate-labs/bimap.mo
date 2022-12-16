import Iter "mo:base-0.7.3/Iter";
import Result "mo:base-0.7.3/Result";

module {
    public type Overwritten<L, R> = {
        #Neither;
        #Right : (L, R);
        #Pair  : (L, R);
        #Left  : (L, R);
        #Both  : ((L, R), (L, R));
    };

    public type BiMap<L, R> = {
        // Returns the number of pairs in the bimap.
        size() : Nat;

        // Returns whether the bimap contains no pairs.
        isEmpty() : Bool;

        // Removes all pairs from the bimap.
        clear() : ();
        
        // Creates an iterator over the left-right pairs in the bimap.
        entries() : Iter.Iter<(L, R)>;

        // Creates an iterator over the left values in the bimap.
        keys() : Iter.Iter<L>;

        // Creates an iterator over the right values in the bimap.
        vals() : Iter.Iter<R>;

        // Returns the right value corresponding to the given left value.
        getByLeft(key : L) : ?R;

        // Returns the left value corresponding to the given right value.
        getByRight(key : R) : ?L;

        // Returns whether the bimap contains the given left value.
        containsLeft(key : L) : Bool;

        // Returns whether the bimap contains the given right value.
        containsRight(key : R) : Bool;

        // Removes the left-right pair corresponding to the given left value.
        // Returns the previous left-right pair if the map contained the left value.
        removeByLeft(key : L) : ?(L, R);

        // Removes the left-right pair corresponding to the given right value.
        // Returns the previous left-right pair if the map contained the right value.
        removeByRight(key : R) : ?(L, R);

        // Inserts the given left-right pair into the bimap.
        // Returns an enum representing any left-right pairs that were overwritten.
        replace(l : L, r : R) : Overwritten<L, R>;

        // Inserts the given left-right pair into the bimap without overwriting any existing values.
        insert(l : L, r : R) : Result.Result<(), (L, R)>;

        // Retains only the elements specified by the predicate.
        // I.e. remove all values for which f returns false.
        retain(f : (L, R) -> Bool) : ();
    };

    public type Map<L, R> = {
        // Returns the number of entries in this map.
        size() : Nat;

        // Returns an iterator over the key value pairs in this map.
        entries() : Iter.Iter<(L, R)>;

        // Gets the entry with the key `k` and returns its associated value if it existed or `null` otherwise.
        get(k : L) : ?R;

        // Removes the entry with the key `k` and returns the associated value if it existed or `null` otherwise.
        remove(k : L) : ?R;

        // Insert the value `v` at key `k`. Overwrites an existing entry with key `k`.
        put(k : L, v : R) : ();
    };

    public class New<L, R>(
        emptyL     : () -> Map<L, R>,
        emptyR     : () -> Map<R, L>,
        rightEqual : (R, R) -> Bool,
    ) : BiMap<L, R> {
        var leftToRight = emptyL();
        var rightToLeft = emptyR();

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
            leftToRight := emptyL();
            rightToLeft := emptyR();
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
    };

    // Copy the current state to a new bimap.
    public func copy<L, R>(
        m : BiMap<L, R>,
        emptyL     : () -> Map<L, R>,
        emptyR     : () -> Map<R, L>,
        rightEqual : (R, R) -> Bool,
    ) : BiMap<L, R> {
        fromIter<L, R>(
            m.entries(),
            emptyL,
            emptyR,
            rightEqual,
        );
    };

    // Convert the given iterator into a new bimap.
    // NOTE: duplicate values will get overwritten!
    public func fromIter<L, R>(
        iter  : Iter.Iter<(L, R)>,
        emptyL : () -> Map<L, R>,
        emptyR : () -> Map<R, L>,
        rightEqual : (R, R) -> Bool,
    ) : BiMap<L, R> {
        let m = New<L, R>(emptyL, emptyR, rightEqual);
        for ((l, r) in iter) { ignore m.replace(l, r); };
        m;
    };
};
