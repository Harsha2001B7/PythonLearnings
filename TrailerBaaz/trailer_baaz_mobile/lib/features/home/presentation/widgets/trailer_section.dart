import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/trailer_model.dart';
import 'trailer_card.dart';

class TrailerSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<TrailerModel> trailers;
  final double cardWidth;
  final ValueChanged<TrailerModel>? onTap;
  final Color? titleColor;
  final bool letterSpaced;
  final bool showTrendingBadge;
  final ScrollController? scrollController;
  final bool fadeTopEdge;

  const TrailerSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.trailers,
    this.cardWidth = 260,
    this.onTap,
    this.titleColor,
    this.letterSpaced = false,
    this.showTrendingBadge = false,
    this.scrollController,
    this.fadeTopEdge = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = (cardWidth * 0.84).clamp(208.0, 244.0);
    Widget body = Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _RevealSectionTitle(
              scrollController: scrollController,
              title: title,
              subtitle: subtitle,
              titleColor: titleColor ?? AppColors.textWhite,
              letterSpaced: letterSpaced,
            ),
          ),
          const SizedBox(height: 14),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.85, 1.0],
              colors: [Colors.white, Colors.transparent],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: SizedBox(
              height: cardHeight,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: trailers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, index) => TrailerCard(
                  trailer: trailers[index],
                  width: cardWidth,
                  showTrendingBadge: showTrendingBadge,
                  onTap: onTap == null ? null : () => onTap!(trailers[index]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    if (fadeTopEdge) {
      body = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.2],
          colors: [Colors.transparent, Color(0xFF0D0D0F)],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: body,
      );
    }

    return body;
  }
}

class _RevealSectionTitle extends StatefulWidget {
  final ScrollController? scrollController;
  final String title;
  final String? subtitle;
  final Color titleColor;
  final bool letterSpaced;

  const _RevealSectionTitle({
    required this.scrollController,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.letterSpaced,
  });

  @override
  State<_RevealSectionTitle> createState() => _RevealSectionTitleState();
}

class _RevealSectionTitleState extends State<_RevealSectionTitle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluate());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.scrollController?.addListener(_evaluate);
  }

  @override
  void didUpdateWidget(covariant _RevealSectionTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_evaluate);
      widget.scrollController?.addListener(_evaluate);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_evaluate);
    _controller.dispose();
    super.dispose();
  }

  void _evaluate() {
    if (_triggered) return;
    final renderObject = context.findRenderObject();
    final scrollController = widget.scrollController;
    if (renderObject is! RenderBox || scrollController == null || !scrollController.hasClients) return;
    final offset = renderObject.localToGlobal(Offset.zero);
    final viewportHeight = MediaQuery.of(context).size.height;
    if (offset.dy < viewportHeight * 0.82) {
      _triggered = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: widget.titleColor,
            fontWeight: FontWeight.w700,
            letterSpacing: widget.letterSpaced ? 1.6 : 0,
          ),
        ),
      ),
    );
    final subtitle = widget.subtitle == null
        ? const SizedBox.shrink()
        : FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(widget.subtitle!, style: const TextStyle(color: AppColors.textGrey)),
              ),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, subtitle],
    );
  }
}
