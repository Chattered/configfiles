rec {
  addDeep = l: r:
    let f = attr:
      { name = attr;
        value = addDeep l.${attr} r.${attr};
      };
    inter = with builtins; listToAttrs (map f (attrNames (intersectAttrs l r)));
    in l // r // inter;
}
