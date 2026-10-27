import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class NicknameDialog extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const NicknameDialog({super.key, required this.pokemon});

  static Future<void> show(BuildContext context, Pokemon pokemon) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => NicknameDialog(pokemon: pokemon),
    );
  }

  @override
  ConsumerState<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends ConsumerState<NicknameDialog> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final currentNickname =
        ref.read(pokemonProvider).getNickname(widget.pokemon.id) ?? '';
    _controller = TextEditingController(text: currentNickname);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveNickname() {
    final text = _controller.text.trim();
    final notifier = ref.read(pokemonProvider.notifier);
    if (text.isEmpty) {
      notifier.removeNickname(widget.pokemon.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nickname removed for ${widget.pokemon.displayName}',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          backgroundColor: const Color(0xFF37474F),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      notifier.setNickname(widget.pokemon.id, text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Assigned nickname "$text" to ${widget.pokemon.displayName}',
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          backgroundColor: const Color(0xFF00897B),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(context).pop();
  }

  void _removeNickname() {
    ref.read(pokemonProvider.notifier).removeNickname(widget.pokemon.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nickname removed for ${widget.pokemon.displayName}',
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        backgroundColor: const Color(0xFF8E061D),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pokemonProvider);
    final currentNickname = state.getNickname(widget.pokemon.id);
    final hasExistingNickname =
        currentNickname != null && currentNickname.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF1E272C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00E676), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF12191D),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00E676),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NICKNAME EDITOR',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF80DEEA),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white60,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF263238),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: widget.pokemon.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.pokemon.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.catching_pokemon,
                                  color: Colors.white38,
                                ),
                              )
                            : const Icon(
                                Icons.catching_pokemon,
                                color: Colors.white38,
                              ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.pokemon.formattedId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF80DEEA),
                              ),
                            ),
                            Text(
                              widget.pokemon.displayName,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (hasExistingNickname)
                              Text(
                                'Current: "$currentNickname"',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: Colors.amberAccent,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'ASSIGN CUSTOM CODENAME',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white54,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLength: 18,
                    autofocus: true,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    cursorColor: Colors.cyanAccent,
                    onSubmitted: (_) => _saveNickname(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2B2D42),
                      hintText: 'e.g. Sparky, Flame, Bubbles...',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white.withAlpha(120),
                        fontSize: 13,
                      ),
                      counterStyle: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: Colors.cyanAccent,
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Colors.white60,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                });
                              },
                            )
                          : null,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF535670),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.cyanAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (hasExistingNickname) ...[
                        TextButton.icon(
                          onPressed: _removeNickname,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Color(0xFFFF5252),
                          ),
                          label: const Text(
                            'REMOVE',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Color(0xFFFF5252),
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ] else ...[
                        const Spacer(),
                      ],

                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Colors.white60,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      ElevatedButton.icon(
                        onPressed: _saveNickname,
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text(
                          'SAVE',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
