The `forkSense` folder must have the following files with the names as specified.
Not all the four files below are used by all scripts,
so you may be able to omit some of them depending on your use case.

* `leftForks_DNAscent_forkSense.bed`
* `rightForks_DNAscent_forkSense.bed`
* `origins_DNAscent_forkSense.bed`
* `terminations_DNAscent_forkSense.bed`

Each file must be space-separated with no column names or headers or comments.
There are eight columns:
* contig name
* 5' end of feature
* 3' end of feature
* read id
* contig name (this is a repeat of the first column)
* 5' end of alignment
* 3' end of alignment
* alignment type ("fwd" or "rev")

If the following line was in, say `leftForks_DNAscent_forkSense.bed`, the interpretation is that
a left fork was marked on the coordinates ~19 kb to ~30 kb on the given read which aligned from
~0 to ~35 kb on `chrI` on the reference genome.

```text
chrI 19274 30037 e9529f28-d27a-497a-be7e-bffdb77e8bc1 chrI 0 35928 fwd
```

