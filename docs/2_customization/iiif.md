## IIIF Presentation Manifest

By default, datura does not offer any behavior for IIIF manifests, so **you will need to add all behavior via overrides on a project by project basis**.

You can hook into the override by adding the following (change class name by type of transformation):

```ruby
class FileCsv
  def transform_iiif
    [transform data]
    [write to @out_iiif/filename]
    [return manifest]
  end
end
```

You can access `@options` and `@out_iiif` from any of the `FileTei` / `FileVra` type classes.

Because Datura does not offer any default behavior, you may program your classes to support IIIF Presentation 2.0 or 3.0.
