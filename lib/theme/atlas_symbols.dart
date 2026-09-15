// ------------------------------------------------------------
// Atlas Design System (ADS) 2.0
//
// Atlas Symbols
//
// Centralized semantic symbol language used throughout Atlas.
//
// Symbols communicate meaning—not decoration.
// Never hardcode emoji in production UI.
//
// Simple. Scalable. Beautiful.
// ------------------------------------------------------------

final class AtlasSymbols {
  AtlasSymbols._();

  // -----------------------------------------------------------------
  // ADS Rules
  //
  // 1. Never hardcode emoji in production UI.
  // 2. Reuse an existing symbol before creating a new one.
  // 3. One concept = one symbol.
  // 4. Symbols represent meaning, not decoration.
  // 5. Keep symbols collector-platform agnostic whenever possible.
  // 6. Group symbols by Atlas domain, not by emoji type.
  // 7. Add new symbols only when no existing semantic match exists.
  // -----------------------------------------------------------------

  // ----------------------------------------------------------
  // Atlas Identity & Core Modules
  // ----------------------------------------------------------

  static const String atlas = '🛡️';
  static const String intelligence = '🧠';
  static const String vault = '🏛️';
  static const String academy = '🎓';
  static const String scan = '📷';
  static const String community = '👥';
  static const String module = '🧩';

  // ----------------------------------------------------------
  // Collection & Vault Domain
  // ----------------------------------------------------------

  static const String collection = '📦';
  static const String instance = '👤';
  static const String owned = '✅';
  static const String wishlist =
      '🎯'; // Replaced ⭐ to avoid clash with favorites/ratings
  static const String missing = '⭕';
  static const String duplicate = '👯'; // Distinct from community/users
  static const String quantity = '📚';
  static const String location = '📍'; // Shelves, binders, bin locations
  static const String provenance = '📜'; // Acquisition history & receipts

  // ----------------------------------------------------------
  // Product Identity & Modifiers
  // ----------------------------------------------------------

  static const String common = '⚪';
  static const String chase = '💎';
  static const String exclusive = '🔥';
  static const String variant = '🎨';
  static const String sticker = '🏷️';
  static const String signed = '✍️';
  static const String limited = '🔢';
  static const String grail = '👑';
  static const String errorPrint = '🔀';
  static const String sealed = '🔒';

  // ----------------------------------------------------------
  // Grading, Authentication & Protection (Universal Collector)
  // ----------------------------------------------------------

  static const String slab = '🖼️'; // Professional grading (PSA, CGC, BGS)
  static const String coa = '🪪'; // Certificate of Authenticity (JSA, Beckett)
  static const String protection =
      '🛡️'; // Soft protector, hard stack, one-touch
  static const String defect =
      '🔬'; // Surface wear, box dings, creases, centering

  // ----------------------------------------------------------
  // Intelligence & Analytics
  // ----------------------------------------------------------

  static const String recommendation = '💡';
  static const String completion = '📊';
  static const String achievement = '🏆';
  static const String dna = '🧬';
  static const String confidence = '🎯'; // Replaced 🧠 to avoid duplicate
  static const String insight = '💭';
  static const String popCensus = '📈'; // Population report density
  static const String scarcity = '💎';

  // ----------------------------------------------------------
  // Review, Audit & Data Engine
  // ----------------------------------------------------------

  static const String reviewVariant =
      '🔀'; // Replaced 🔍 to avoid duplicate with search
  static const String review = '🧐';
  static const String verify = '🛡️';
  static const String evidence = '⚖️';
  static const String conflict = '⚔️';
  static const String needsReview = '❓';
  static const String canonical = '🔗'; // Unlinked item mapped to core catalog

  // ----------------------------------------------------------
  // Value, Market & Commerce
  // ----------------------------------------------------------

  static const String value = '💰';
  static const String trendUp = '📈';
  static const String trendDown = '📉';
  static const String market = '💲';
  static const String comp = '🏷️'; // Comparable sold listing
  static const String volatility = '📊';
  static const String listing = '💼'; // For Sale, eBay/TCG listing
  static const String trade = '🔄'; // Trade equity / swap ledger

  // ----------------------------------------------------------
  // Universal Scanner Engines
  // ----------------------------------------------------------

  static const String engineBarcode = '🏁';
  static const String engineSlab = '🏷️';
  static const String engineOcr = '👁️';
  static const String voiceInput = '🎙️';

  // ----------------------------------------------------------
  // Health & System States
  // ----------------------------------------------------------

  static const String health = '❤️';
  static const String cleanup = '🧹';
  static const String warning = '⚠️';
  static const String danger = '❌';
  static const String success = '🌟'; // Replaced ✅ to avoid clash with owned
  static const String info = 'ℹ️';

  // ----------------------------------------------------------
  // System, Sync & Platform
  // ----------------------------------------------------------

  static const String ai = '🤖';
  static const String timeline = '🕒';
  static const String search = '🔍';
  static const String premium = '⭐'; // Replaced 👑 to keep grail unique
  static const String cloud = '☁️';
  static const String importData = '📥';
  static const String exportData = '📤';
  static const String loading = '⏳';
  static const String empty = '📭';
  static const String settings = '⚙️';

  // ----------------------------------------------------------
  // Social & Community
  // ----------------------------------------------------------

  static const String friend = '🤝';
  static const String share = '📤';
  static const String comment = '💬';
  static const String favorite = '❤️';
  static const String follow = '👣';
  static const String group = '👥';
}
