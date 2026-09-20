// lib/providers/player_ui_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// True when the user has minimized the Now Playing screen. Audio keeps
/// playing in the background and a floating bubble is shown instead.
final isPlayerMinimizedProvider = StateProvider<bool>((ref) => false);

/// Where the user last dragged the floating mini player to.
/// Null means "hasn't been dragged yet — use the default position".
final miniPlayerOffsetProvider = StateProvider<Offset?>((ref) => null);