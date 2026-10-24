import 'package:flutter/material.dart';

/// Centralized border radii tokens for Learno.
///
/// Features expressive, rounded geometry tailored for a playful, curious aesthetic.
abstract final class AppRadii {
  // --- Raw Radius Values ---
  static const double none = 0.0;
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double pill = 999.0;

  // --- Semantic Radius Values ---
  static const double button = 16.0;
  static const double card = 22.0;
  static const double input = 16.0;
  static const double dialog = 24.0;
  static const double chip = 999.0;

  // --- Radius Helpers ---
  static const Radius rXs = Radius.circular(xs);
  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);
  static const Radius rPill = Radius.circular(pill);

  // --- BorderRadius Helpers ---
  static const BorderRadius borderXs = BorderRadius.all(rXs);
  static const BorderRadius borderSm = BorderRadius.all(rSm);
  static const BorderRadius borderMd = BorderRadius.all(rMd);
  static const BorderRadius borderLg = BorderRadius.all(rLg);
  static const BorderRadius borderXl = BorderRadius.all(rXl);
  static const BorderRadius borderPill = BorderRadius.all(rPill);

  // --- Component Specific BorderRadius ---
  static const BorderRadius borderButton = BorderRadius.all(
    Radius.circular(button),
  );
  static const BorderRadius borderCard = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius borderInput = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius borderDialog = BorderRadius.all(
    Radius.circular(dialog),
  );
  static const BorderRadius borderChip = BorderRadius.all(
    Radius.circular(chip),
  );
}
