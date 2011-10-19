pir::loadlib__Ps('select');

class IO::Select {
    has $!pmc;
    has $!iter = 'FH1';
    has %!handles;

    submethod BUILD {
        $!pmc := pir::new__Ps('Select');
    }

    method add($handle) {
        %!handles{$!iter} = $handle;
        my Mu $fh := nqp::getattr(
            pir::perl6_decontainerize__PP($handle), $handle.WHAT, '$!PIO'
        );
        my $mode = 4;
        if pir::can($fh, 'mode') {
            $mode += 2 if nqp::p6box_s($fh.mode) eq 'w';
            $mode += 1 if nqp::p6box_s($fh.mode) eq 'r';
        } else {
            $mode += 3; # XXX We just assume it's IO::Socket or so
        }
        # XXX No idea how to obtain an actual fd or any other unique
        # identifier, so I'll just assign consequent letters of alphabet
        # to each one
        $!pmc.update($fh, nqp::unbox_s($!iter), nqp::unbox_i($mode));
        $!iter.=succ;
    }

    method can_read($timeout as Num) {
        my @parcel := $!pmc.can_read(nqp::unbox_n($timeout));
        return self.get_handles(@parcel);
    }

    method can_write($timeout as Num) {
        my @parcel := $!pmc.can_write(nqp::unbox_n($timeout));
        return self.get_handles(@parcel);
    }

    method get_handles(@parcel) {
        my Mu $ids := nqp::getattr(
            @parcel, Parcel, '$!storage'
        );
        my int $elems = pir::elements($ids);
        my @res;
        loop (my int $i = 0; $i < $elems; $i = $i + 1) {
            my Str $item := nqp::p6box_s(nqp::atpos($ids, $i));
            @res.push: %!handles{$item};
        }
        return @res;
    }
}
