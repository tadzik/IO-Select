pir::loadlib__Ps('select');

class IO::Select {
    has $!pmc;

    submethod BUILD {
        $!pmc := pir::new__Ps('Select');
    }

    method add($handle) {
        my Mu $fh := nqp::getattr(
            nqp::decont($handle), $handle.WHAT, '$!PIO'
        );
        my $mode = 4;
        if nqp::can($fh, 'mode') {
            $mode += 2 if nqp::p6box_s($fh.mode) eq 'w';
            $mode += 1 if nqp::p6box_s($fh.mode) eq 'r';
        } else {
            $mode += 3; # XXX We just assume it's IO::Socket or so
        }
        $!pmc.update($fh, $handle, nqp::unbox_i($mode));
    }

    method can_read($timeout as Num) {
        $!pmc.can_read(nqp::unbox_n($timeout));
    }

    method can_write($timeout as Num) {
        $!pmc.can_write(nqp::unbox_n($timeout));
    }
}
