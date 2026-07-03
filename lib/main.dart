import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const IstoKingApp());
}

class IstoKingApp extends StatelessWidget {
  const IstoKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isto King',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: RoyalColors.parchment,
        colorScheme: ColorScheme.fromSeed(seedColor: RoyalColors.red),
        fontFamily: 'Georgia',
      ),
      home: const IstoGameScreen(),
    );
  }
}

class RoyalColors {
  static const parchment = Color(0xFFFBE9C9);
  static const parchmentLight = Color(0xFFFFF4D6);
  static const boardCell = Color(0xFFFDE7C2);
  static const red = Color(0xFFD7262E);
  static const green = Color(0xFF3B8E32);
  static const blue = Color(0xFF006FBE);
  static const yellow = Color(0xFFF5A400);
  static const darkRed = Color(0xFF700000);
  static const brown = Color(0xFF6B3A1E);
  static const darkBrown = Color(0xFF3A1E0F);
  static const gold = Color(0xFFEBA318);
  static const outerRed = Color(0xFF7B0D06);
}

class IstoGameScreen extends StatefulWidget {
  const IstoGameScreen({super.key});

  @override
  State<IstoGameScreen> createState() => _IstoGameScreenState();
}

class _IstoGameScreenState extends State<IstoGameScreen> {
  int _currentPlayerIndex = 0;
  final List<int?> _lastRolls = List<int?>.filled(4, null);

  void _handleRollComplete(int playerIndex, int value) {
    setState(() {
      _lastRolls[playerIndex] = value;
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _lastRolls.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: RoyalColors.parchment),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: ScreenOrnamentPainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  final compact = height < 820;
                  final horizontalPadding = width < 410 ? 12.0 : 16.0;
                  final topBarHeight = compact ? 58.0 : 66.0;
                  final cardHeight = compact ? 90.0 : 100.0;
                  const gap = 7.0;
                  final boardMaxWidth = width - horizontalPadding * 2;
                  final boardMaxHeight =
                      height - topBarHeight - cardHeight * 2 - gap * 3;
                  final boardSize = math.max(
                    280.0,
                    math.min(boardMaxWidth, boardMaxHeight),
                  );

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: topBarHeight,
                          child: const TopGameBar(),
                        ),
                        const SizedBox(height: gap),
                        SizedBox(
                          height: cardHeight,
                          child: PlayerRow(
                            left: PlayerCard(
                              name: 'Rammohan',
                              color: RoyalColors.red,
                              avatarAsset: 'assets/avatar/avatar-1.png',
                              isActive: _currentPlayerIndex == 0,
                              onRollComplete: (value) =>
                                  _handleRollComplete(0, value),
                            ),
                            right: PlayerCard(
                              name: 'Chandrakishore',
                              color: RoyalColors.green,
                              avatarAsset: 'assets/avatar/avatar-f-1.png',
                              avatarOnRight: true,
                              isActive: _currentPlayerIndex == 1,
                              onRollComplete: (value) =>
                                  _handleRollComplete(1, value),
                            ),
                          ),
                        ),
                        const SizedBox(height: gap),
                        Center(
                          child: SizedBox.square(
                            dimension: boardSize,
                            child: const GameBoard(),
                          ),
                        ),
                        const SizedBox(height: gap),
                        SizedBox(
                          height: cardHeight,
                          child: PlayerRow(
                            left: PlayerCard(
                              name: 'Aaradhya',
                              color: RoyalColors.yellow,
                              avatarAsset: 'assets/avatar/avatar-2.png',
                              isActive: _currentPlayerIndex == 2,
                              onRollComplete: (value) =>
                                  _handleRollComplete(2, value),
                            ),
                            right: PlayerCard(
                              name: 'Shaurya',
                              color: RoyalColors.blue,
                              avatarAsset: 'assets/avatar/avatar-f-2.png',
                              avatarOnRight: true,
                              isActive: _currentPlayerIndex == 3,
                              onRollComplete: (value) =>
                                  _handleRollComplete(3, value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopGameBar extends StatelessWidget {
  const TopGameBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          left: 0,
          child: RoundIconButton(icon: Icons.arrow_back),
        ),
        const Positioned(
          right: 0,
          child: RoundIconButton(icon: Icons.settings),
        ),
        Positioned(right: 48, child: const CoinBalancePill()),
      ],
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RoyalColors.outerRed,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.brown.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class CoinBalancePill extends StatelessWidget {
  const CoinBalancePill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.fromLTRB(6, 3, 3, 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE1B2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: RoyalColors.brown.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: RoyalColors.brown.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CoinIcon(size: 24),
          SizedBox(width: 6),
          Text(
            '120',
            style: TextStyle(
              color: RoyalColors.darkBrown,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
          SizedBox(width: 7),
          CircleAvatar(
            radius: 13,
            backgroundColor: Color(0xFF3AAA45),
            child: Icon(Icons.add, color: Colors.white, size: 19),
          ),
        ],
      ),
    );
  }
}

class PlayerRow extends StatelessWidget {
  const PlayerRow({required this.left, required this.right, super.key});

  final PlayerCard left;
  final PlayerCard right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.name,
    required this.color,
    required this.avatarAsset,
    this.avatarOnRight = false,
    this.shellCount = 4,
    this.isActive = false,
    this.onRollComplete,
    super.key,
  });

  final String name;
  final Color color;
  final String avatarAsset;
  final bool avatarOnRight;
  final int shellCount;
  final bool isActive;
  final ValueChanged<int>? onRollComplete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final avatarSize = height * 0.68;
        final cardLeft = avatarSize * 0.36;
        final cardTop = height * 0.12;
        final cardBottom = height * 0.03;
        final contentLeft = avatarSize * 0.76;
        final nameSize = height < 96 ? 15.0 : 17.0;
        final contentWidth = constraints.maxWidth - cardLeft - contentLeft - 9;
        final shellSize = math.min(
          height < 96 ? 38.0 : 42.0,
          contentWidth / 2.95,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              left: avatarOnRight ? 0 : cardLeft,
              right: avatarOnRight ? cardLeft : 0,
              top: cardTop,
              bottom: cardBottom,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: isActive ? 0.58 : 0.35),
                      blurRadius: isActive ? 18 : 12,
                      spreadRadius: isActive ? 1 : 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: avatarOnRight ? 9 : contentLeft,
                    right: avatarOnRight ? contentLeft : 9,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: avatarOnRight
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: nameSize + 4,
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: avatarOnRight
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Text(
                            name,
                            maxLines: 1,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: nameSize,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              shadows: const [
                                Shadow(
                                  color: RoyalColors.brown,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      CowrieRollPanel(
                        playerColor: color,
                        isActive: isActive,
                        shellCount: shellCount,
                        shellSize: shellSize,
                        alignRight: avatarOnRight,
                        onRollComplete: onRollComplete,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: avatarOnRight ? null : 0,
              right: avatarOnRight ? 0 : null,
              top: height * 0.14,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Padding(
                  padding: EdgeInsets.all(avatarSize * 0.04),
                  child: ClipOval(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: ColoredBox(
                      color: RoyalColors.parchmentLight,
                      child: SizedBox.square(
                        dimension: avatarSize * 0.92,
                        child: Image.asset(
                          avatarAsset,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CoinIcon extends StatelessWidget {
  const CoinIcon({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: CoinPainter()),
    );
  }
}

class CowrieShell extends StatefulWidget {
  const CowrieShell({
    required this.startOpen,
    required this.resultOpen,
    required this.isRolling,
    required this.rollCycle,
    required this.delayIndex,
    required this.size,
    required this.width,
    super.key,
  });

  final bool startOpen;
  final bool resultOpen;
  final bool isRolling;
  final int rollCycle;
  final int delayIndex;
  final double size;
  final double width;

  @override
  State<CowrieShell> createState() => _CowrieShellState();
}

class _CowrieShellState extends State<CowrieShell> {
  static const int _delayMs = 165;
  static const int _spinMs = 1000;
  static const int _settleMs = 160;
  static const double _landingStart = 0.82;

  bool? _spinStartOpen;
  bool? _spinResultOpen;

  int get _tumbleHalfFlips => 4 + (widget.delayIndex % 2);

  @override
  void didUpdateWidget(CowrieShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rollCycle > oldWidget.rollCycle ||
        (widget.isRolling && !oldWidget.isRolling)) {
      _spinStartOpen = widget.startOpen;
      _spinResultOpen = widget.resultOpen;
    }
  }

  Widget _shellImage(bool isOpen) => Image.asset(
    isOpen
        ? 'assets/images/cowrie_open.png'
        : 'assets/images/cowrie_closed.png',
    width: widget.width,
    height: widget.size,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
  );

  Widget _buildSettledShell() {
    return SizedBox(
      width: widget.width,
      height: widget.size,
      child: _shellImage(_spinResultOpen ?? widget.resultOpen),
    );
  }

  bool _faceBeforeLanding(bool startOpen) {
    return _tumbleHalfFlips.isEven ? startOpen : !startOpen;
  }

  Widget _buildFlipFrame(double value) {
    final startOpen = _spinStartOpen ?? widget.startOpen;
    final resultOpen = _spinResultOpen ?? widget.resultOpen;
    final pop = math.sin(value * math.pi);
    final wobble =
        math.sin(value * math.pi * 4 + widget.delayIndex) * 1.8 * pop;
    final scale = 1.0 + pop * 0.24;
    final lift = -pop * 8;

    late final double verticalSpin;
    late final bool showOpen;

    if (value >= _landingStart) {
      final landValue = (value - _landingStart) / (1 - _landingStart);
      final showingResult = landValue >= 0.5;
      final halfProgress = showingResult ? (landValue - 0.5) * 2 : landValue * 2;
      final landingSpin = showingResult
          ? -math.pi / 2 + halfProgress * math.pi / 2
          : halfProgress * math.pi / 2;
      verticalSpin = _tumbleHalfFlips * math.pi / 2 + landingSpin;
      showOpen = showingResult ? resultOpen : _faceBeforeLanding(startOpen);
    } else {
      final tumbleValue = Curves.easeOut.transform(value / _landingStart);
      verticalSpin = tumbleValue * _tumbleHalfFlips * math.pi / 2;
      final halfFlipIndex = (verticalSpin / (math.pi / 2)).floor();
      showOpen = halfFlipIndex.isEven ? startOpen : !startOpen;
    }

    return Transform.translate(
      offset: Offset(wobble, lift),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0016)
          ..rotateY(verticalSpin),
        child: Transform.scale(
          scale: scale,
          child: _shellImage(showOpen),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRolling) {
      return _buildSettledShell();
    }

    final startOpen = _spinStartOpen ?? widget.startOpen;
    final totalMs = _spinMs + _settleMs;
    final flipEnd = _spinMs / totalMs;

    return SizedBox(
      width: widget.width,
      height: widget.size,
      child: _shellImage(startOpen)
          .animate(
            key: ValueKey('cowrie-${widget.rollCycle}-${widget.delayIndex}'),
            delay: (widget.delayIndex * _delayMs).ms,
          )
          .custom(
            duration: totalMs.ms,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              if (value >= flipEnd) {
                final settleT = (value - flipEnd) / (1 - flipEnd);
                final bounce = 1.0 + math.sin(settleT * math.pi) * 0.05;
                final resultOpen = _spinResultOpen ?? widget.resultOpen;
                return Transform.scale(
                  scale: bounce,
                  child: _shellImage(resultOpen),
                );
              }
              return _buildFlipFrame(value / flipEnd);
            },
          ),
    );
  }
}

class CowrieRollPanel extends StatefulWidget {
  const CowrieRollPanel({
    required this.playerColor,
    required this.isActive,
    required this.shellCount,
    required this.shellSize,
    this.alignRight = false,
    this.onRollComplete,
    super.key,
  });

  final Color playerColor;
  final bool isActive;
  final int shellCount;
  final double shellSize;
  final bool alignRight;
  final ValueChanged<int>? onRollComplete;

  @override
  State<CowrieRollPanel> createState() => _CowrieRollPanelState();
}

class _CowrieRollPanelState extends State<CowrieRollPanel> {
  static const int _shellDelayMs = 165;
  static const int _shellSpinMs = 1000;
  static const int _shellSettleMs = 160;

  final math.Random _random = math.Random();
  late List<bool> _cowries;
  List<bool>? _rollingCowries;
  bool _isRolling = false;
  int _rollCycle = 0;

  @override
  void initState() {
    super.initState();
    _cowries = List<bool>.filled(widget.shellCount, true);
  }

  @override
  void didUpdateWidget(covariant CowrieRollPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shellCount != widget.shellCount) {
      _cowries = List<bool>.filled(widget.shellCount, true);
    }
    if (oldWidget.isActive && !widget.isActive) {
      _cowries = List<bool>.filled(widget.shellCount, true);
      _rollingCowries = null;
      _isRolling = false;
    }
  }

  Future<void> _rollCowries() async {
    if (!widget.isActive || _isRolling) return;

    final finalCowries = _generateFinalCowries();
    final result = _calculateIstoValue(finalCowries);
    final nextRollCycle = _rollCycle + 1;

    setState(() {
      _isRolling = true;
      _rollCycle = nextRollCycle;
      _rollingCowries = finalCowries;
    });

    await Future<void>.delayed(
      Duration(
        milliseconds:
            _shellDelayMs * (widget.shellCount - 1) +
            _shellSpinMs +
            _shellSettleMs +
            80,
      ),
    );
    if (!mounted || _rollCycle != nextRollCycle) return;

    setState(() {
      _cowries = finalCowries;
      _rollingCowries = null;
      _isRolling = false;
    });

    widget.onRollComplete?.call(result);
  }

  List<bool> _generateFinalCowries() {
    return List<bool>.generate(widget.shellCount, (_) => _random.nextBool());
  }

  int _calculateIstoValue(List<bool> cowries) {
    final openCount = cowries.where((isOpen) => isOpen).length;
    return openCount == 0 ? 8 : openCount;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return SizedBox(height: widget.shellSize);
    }

    return Semantics(
      button: true,
      enabled: true,
      label: 'Roll cowries',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _rollCowries,
        child: SizedBox(
          width: double.infinity,
          height: widget.shellSize,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final shellWidth = widget.shellSize * 0.68;
              final desiredGap = widget.shellSize * 0.2;
              final fittedGap = widget.shellCount <= 1
                  ? 0.0
                  : (constraints.maxWidth - shellWidth * widget.shellCount) /
                        (widget.shellCount - 1);
              final gap = math.max(0.0, math.min(desiredGap, fittedGap));
              final step = shellWidth + gap;
              final rowWidth =
                  shellWidth * widget.shellCount +
                  gap * (widget.shellCount - 1);
              final startX = widget.alignRight
                  ? constraints.maxWidth - rowWidth
                  : 0.0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var index = 0; index < widget.shellCount; index++)
                    Positioned(
                      left: startX + step * index,
                      top: 0,
                      child: CowrieShell(
                        startOpen: _cowries[index],
                        resultOpen:
                            _rollingCowries?[index] ?? _cowries[index],
                        isRolling: _isRolling,
                        rollCycle: _rollCycle,
                        delayIndex: index,
                        size: widget.shellSize,
                        width: shellWidth,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: const CustomPaint(painter: GameBoardPainter()),
    );
  }
}

class CurrentTurnBanner extends StatelessWidget {
  const CurrentTurnBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: RoyalColors.boardCell,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: RoyalColors.gold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: RoyalColors.brown.withValues(alpha: 0.16),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✣',
                style: TextStyle(color: RoyalColors.gold, fontSize: 17),
              ),
              SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Current Turn:',
                    style: TextStyle(
                      color: RoyalColors.darkBrown,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              CircleAvatar(radius: 8, backgroundColor: RoyalColors.red),
              SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Rammohan',
                    style: TextStyle(
                      color: RoyalColors.red,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                '✣',
                style: TextStyle(color: RoyalColors.gold, fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameBoardPainter extends CustomPainter {
  const GameBoardPainter();

  static const int gridCount = 5;
  static const playerHomes = [
    BoardPlayerHome(
      col: 2,
      row: 0,
      color: RoyalColors.red,
      arrowAngle: math.pi / 2,
      arrowCol: 3,
    ),
    BoardPlayerHome(
      col: 2,
      row: 4,
      color: RoyalColors.blue,
      arrowAngle: -math.pi / 2,
    ),
    BoardPlayerHome(
      col: 0,
      row: 2,
      color: RoyalColors.yellow,
      arrowAngle: 0,
      arrowCol: 0,
      arrowRow: 1,
    ),
    BoardPlayerHome(
      col: 4,
      row: 2,
      color: RoyalColors.green,
      arrowAngle: math.pi,
      arrowCol: 4,
      arrowRow: 3,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final boardRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: shortest,
      height: shortest,
    ).deflate(1);
    final borderWidth = math.max(4.0, shortest * 0.018);
    final outer = RRect.fromRectAndRadius(
      boardRect.deflate(borderWidth / 2),
      const Radius.circular(19),
    );
    final inner = boardRect.deflate(shortest * 0.032);
    final innerRRect = RRect.fromRectAndRadius(
      inner,
      const Radius.circular(12),
    );
    final cell = inner.width / gridCount;

    canvas.drawRRect(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = RoyalColors.darkRed,
    );
    canvas.drawRRect(innerRRect, Paint()..color = RoyalColors.boardCell);

    for (final home in playerHomes) {
      _drawPlayerHomeCell(
        canvas,
        _cellRect(inner, cell, home.col, home.row),
        home.color,
      );
    }

    _drawGrid(canvas, inner, innerRRect, cell);
    _drawCenterHome(canvas, _cellRect(inner, cell, 2, 2));

    for (final home in playerHomes) {
      _drawCrossLines(canvas, _cellRect(inner, cell, home.col, home.row));
    }

    for (final home in playerHomes) {
      _drawArrow(
        canvas,
        _cellRect(inner, cell, home.arrowCol, home.arrowRow),
        home.color,
        home.arrowAngle,
      );
    }

    for (final home in playerHomes) {
      _drawTokenCluster(
        canvas,
        _cellRect(inner, cell, home.col, home.row),
        home.color,
      );
    }
  }

  Rect _cellRect(Rect board, double cell, int col, int row) {
    return Rect.fromLTWH(
      board.left + col * cell,
      board.top + row * cell,
      cell,
      cell,
    );
  }

  void _drawPlayerHomeCell(Canvas canvas, Rect rect, Color color) {
    canvas.drawRect(rect, Paint()..color = color);
  }

  void _drawGrid(Canvas canvas, Rect board, RRect border, double cell) {
    final line = Paint()
      ..color = RoyalColors.brown
      ..strokeWidth = math.max(1.0, cell * 0.035);
    for (var i = 1; i < gridCount; i++) {
      final offset = board.left + i * cell;
      canvas.drawLine(
        Offset(offset, board.top),
        Offset(offset, board.bottom),
        line,
      );
      final y = board.top + i * cell;
      canvas.drawLine(Offset(board.left, y), Offset(board.right, y), line);
    }
    canvas.drawRRect(border, line..style = PaintingStyle.stroke);
  }

  void _drawCenterHome(Canvas canvas, Rect rect) {
    final center = rect.center;
    final colors = [
      RoyalColors.red,
      RoyalColors.green,
      RoyalColors.blue,
      RoyalColors.yellow,
    ];
    final points = [
      [rect.topLeft, rect.topRight, center],
      [rect.topRight, rect.bottomRight, center],
      [rect.bottomRight, rect.bottomLeft, center],
      [rect.bottomLeft, rect.topLeft, center],
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(points[i][0].dx, points[i][0].dy)
          ..lineTo(points[i][1].dx, points[i][1].dy)
          ..lineTo(points[i][2].dx, points[i][2].dy)
          ..close(),
        Paint()..color = colors[i],
      );
    }
    _drawCrossLines(canvas, rect);
  }

  void _drawCrossLines(Canvas canvas, Rect rect) {
    final cross = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(1.5, rect.width * 0.035)
      ..strokeCap = StrokeCap.butt;
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawLine(rect.topLeft, rect.bottomRight, cross);
    canvas.drawLine(rect.topRight, rect.bottomLeft, cross);
    canvas.restore();
  }

  void _drawTokenCluster(
    Canvas canvas,
    Rect rect,
    Color color, [
    int count = 4,
  ]) {
    final radius = rect.width * 0.13;
    final offsets = count == 3
        ? [
            Offset(rect.center.dx, rect.top + rect.height * 0.24),
            Offset(rect.center.dx, rect.center.dy),
            Offset(rect.center.dx, rect.bottom - rect.height * 0.24),
          ]
        : [
            Offset(rect.center.dx - rect.width / 3, rect.center.dy),
            Offset(rect.center.dx, rect.center.dy - rect.height / 3),
            Offset(rect.center.dx, rect.center.dy + rect.height / 3),
            Offset(rect.center.dx + rect.width / 3, rect.center.dy),
          ];
    for (final offset in offsets) {
      _drawToken(canvas, offset, radius, color);
    }
  }

  void _drawToken(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Colors.black,
      2,
      true,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Color.lerp(color, Colors.black, 0.12)!,
    );
    canvas.drawCircle(
      center.translate(-radius * 0.15, -radius * 0.15),
      radius * 0.78,
      Paint()..color = color,
    );
    canvas.drawCircle(
      center,
      radius * 0.76,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.18
        ..color = Colors.white,
    );
    _drawStar(canvas, center, radius * 0.5, Colors.white);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawArrow(Canvas canvas, Rect rect, Color color, double angle) {
    canvas.save();
    canvas.translate(rect.center.dx, rect.center.dy);
    canvas.rotate(angle);
    final length = rect.width * 0.78;
    final shadowPath = Path()
      ..moveTo(length * 0.42, 0)
      ..lineTo(length * 0.03, -length * 0.27)
      ..lineTo(length * 0.1, -length * 0.1)
      ..lineTo(-length * 0.36, -length * 0.1)
      ..lineTo(-length * 0.36, length * 0.1)
      ..lineTo(length * 0.1, length * 0.1)
      ..lineTo(length * 0.03, length * 0.27)
      ..close();
    canvas.drawShadow(shadowPath, Colors.black, 2, true);
    final path = Path()
      ..moveTo(length * 0.42, 0)
      ..lineTo(length * 0.03, -length * 0.27)
      ..lineTo(length * 0.1, -length * 0.1)
      ..lineTo(-length * 0.36, -length * 0.1)
      ..lineTo(-length * 0.36, length * 0.1)
      ..lineTo(length * 0.1, length * 0.1)
      ..lineTo(length * 0.03, length * 0.27)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, rect.width * 0.028)
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BoardPlayerHome {
  const BoardPlayerHome({
    required this.col,
    required this.row,
    required this.color,
    required this.arrowAngle,
    int? arrowCol,
    int? arrowRow,
  }) : arrowCol = arrowCol ?? col - 1,
       arrowRow = arrowRow ?? row;

  final int col;
  final int row;
  final Color color;
  final double arrowAngle;
  final int arrowCol;
  final int arrowRow;
}

class CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFB86A00));
    canvas.drawCircle(
      center.translate(-radius * 0.08, -radius * 0.08),
      radius * 0.82,
      Paint()..color = RoyalColors.gold,
    );
    canvas.drawCircle(
      center,
      radius * 0.66,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.13
        ..color = const Color(0xFFFFF078),
    );
    const starColor = Color(0xFFFFF6A3);
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius * 0.44 : radius * 0.2;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = starColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CowrieShellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shell = Path()
      ..moveTo(rect.width * 0.18, rect.height * 0.78)
      ..cubicTo(
        rect.width * 0.02,
        rect.height * 0.38,
        rect.width * 0.33,
        rect.height * 0.02,
        rect.width * 0.64,
        rect.height * 0.08,
      )
      ..cubicTo(
        rect.width * 0.98,
        rect.height * 0.15,
        rect.width * 0.98,
        rect.height * 0.66,
        rect.width * 0.62,
        rect.height * 0.9,
      )
      ..cubicTo(
        rect.width * 0.45,
        rect.height,
        rect.width * 0.25,
        rect.height * 0.96,
        rect.width * 0.18,
        rect.height * 0.78,
      )
      ..close();
    canvas.drawShadow(shell, Colors.black, 2, true);
    canvas.drawPath(shell, Paint()..color = const Color(0xFFFFF4D7));
    final slit = Paint()
      ..color = RoyalColors.brown
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.2),
      Offset(size.width * 0.36, size.height * 0.82),
      slit,
    );
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.28 + i * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.5, y),
        Offset(size.width * 0.61, y + size.height * 0.04),
        Paint()
          ..color = RoyalColors.brown.withValues(alpha: 0.65)
          ..strokeWidth = size.width * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScreenOrnamentPainter extends CustomPainter {
  const ScreenOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = RoyalColors.outerRed;
    for (final corner in [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ]) {
      final sx = corner.dx == 0 ? 1.0 : -1.0;
      final sy = corner.dy == 0 ? 1.0 : -1.0;
      canvas.save();
      canvas.translate(corner.dx, corner.dy);
      canvas.scale(sx, sy);
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(96, 0)
        ..cubicTo(74, 3, 65, 15, 61, 31)
        ..cubicTo(55, 52, 39, 63, 20, 64)
        ..cubicTo(9, 65, 2, 74, 0, 88)
        ..close();
      canvas.drawPath(path, red);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
