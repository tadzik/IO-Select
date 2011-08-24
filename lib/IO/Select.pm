pir::loadlib__Ps('select');

class IO::Select {
    has $!pmc;
    has $!iter = 'FH1';
    has %!handles;
    
    submethod BUILD {
        $!pmc := pir::new__Ps('Select');
    }

    method add(IO $handle) {
        %!handles{$!iter} = $handle;
        my $fh := nqp::getattr(
            pir::perl6_decontainerize__PP($handle), IO, '$!PIO'
        );
        my $mode = 4;
        $mode += 2 if nqp::p6box_s($fh.mode) eq 'w';
        $mode += 1 if nqp::p6box_s($fh.mode) eq 'r';
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
        my Int $elems := nqp::p6box_i(pir::elements($ids));
        my @res;
        loop (my Int $i = 0; $i < $elems; $i++) {
            my Str $item := nqp::p6box_s(nqp::atpos($ids, nqp::unbox_i($i)));
            @res.push: %!handles{$item};
        }
        return @res;
    }
}
