(lang dune 3.15)
(version 0.2.0)
(name lilv)
(source (github savonet/ocaml-lilv))
(license LGPL-2.1)
(authors "Samuel Mimram <smimram@gmail.com>")
(maintainers "The Savonet Team <savonet-users@lists.sourceforge.net>")

(generate_opam_files true)
(using ctypes 0.3)

(package
 (name lilv)
 (synopsis "Bindings to lilv library for using LV2 audio plugins")
 (description "Bindings to the lilv library for simple use of LV2 plugins in applications. LV2 is an open extensible standard for audio plugins. Many types of plugins can be built with LV2, including audio effects, synthesizers, and control processors for modulation and automation.")
 (depends
  conf-pkg-config
  conf-lilv
  dune
  dune-configurator
  ctypes
  ctypes-foreign))
