import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../bloc/aircraft/exporter_cubit.dart';
import '../../bloc/showcase_cubit.dart';
import '../../constants/colors.dart' as colors;
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../app/dialogs.dart';
import '../showcase/showcase_item.dart';
import './components/toolbar_actions.dart';
// import 'components/location_search.dart';
import 'components/scanning_state_icons.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({
    super.key,
  });

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  bool wakelock = false;
  bool logging = false;

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    const borderRadius = Radius.circular(Sizes.panelBorderRadius);
    final toolbarColor = colors.AppColors.toolbarColor
        .withOpacity(colors.AppColors.toolbarOpacity);
    return Container(
      decoration: BoxDecoration(
        boxShadow: const <BoxShadow>[
          BoxShadow(
            blurRadius: Sizes.panelBorderRadius,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          )
        ],
        borderRadius: const BorderRadius.all(
          borderRadius,
        ),
        color: toolbarColor,
      ),
      margin: EdgeInsets.symmetric(
        vertical: statusBarHeight + Sizes.mapContentMargin,
        horizontal: Sizes.mapContentMargin,
      ),
      padding: const EdgeInsets.symmetric(horizontal: Sizes.toolbarMargin),
      height: Sizes.toolbarHeight,
      child: ShowcaseItem(
        showcaseKey: context.read<ShowcaseCubit>().searchKey,
        description: context.read<ShowcaseCubit>().searchDescription,
        title: 'Map Toolbar',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // const Expanded(
            //   flex: 2,
            //   child: LocationSearch(),
            // ),

            Expanded(child: Container()),
            Expanded(
              flex: 1,
              child: ShowcaseItem(
                showcaseKey: context.read<ShowcaseCubit>().scanningStateKey,
                description:
                    context.read<ShowcaseCubit>().scanningStateDescription,
                title: 'Map Toolbar',
                child: const ScanningStateIcons(),
              ),
            ),
            RawMaterialButton(
              onPressed: () {
                setState(() {
                  wakelock = !wakelock;
                  showSnackBar(
                    context,
                    "Screen Lock ${wakelock ? "Enabled." : "Disabled."}",
                  );
                  WakelockPlus.toggle(enable: wakelock);
                });
              },
              constraints: const BoxConstraints(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const CircleBorder(),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Icon(
                    Icons.phonelink_lock,
                    color:
                        wakelock ? Colors.white : AppColors.iconDisabledColor,
                    size: Sizes.iconSize,
                  ),
                  if (!wakelock)
                    Transform.rotate(
                      angle: -math.pi / 4,
                      child: Container(
                        width: Sizes.iconSize / 8,
                        height: Sizes.iconSize + 3,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            RawMaterialButton(
              onPressed: () async {
                if (logging) {
                  var res = await context.read<ExporterCubit>().stopLogger();
                  if (mounted) {
                    if (res is bool && res) {
                      logging = false;
                      showSnackBar(
                        context,
                        "Logging Stopped.",
                      );
                    } else {
                      var e = res as Exception;
                      showSnackBar(
                        context,
                        "Logging Stop Error: ${e.toString()}",
                      );
                    }
                  }
                } else {
                  var res = await context.read<ExporterCubit>().startLogger();
                  if (mounted) {
                    if (res is bool && res) {
                      logging = true;
                      showSnackBar(
                        context,
                        "Logging Started.",
                      );
                    } else {
                      var e = res as Exception;

                      showSnackBar(
                        context,
                        "Logging Start Error: ${e.toString()}",
                      );
                    }
                  }
                }
                setState(() {});
              },
              constraints: const BoxConstraints(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const CircleBorder(),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Icon(
                    logging
                        ? Icons.stop_circle_rounded
                        : Icons.radio_button_checked_rounded,
                    color: Colors.red,
                    size: Sizes.iconSize,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            ShowcaseItem(
              showcaseKey: context.read<ShowcaseCubit>().showInfoKey,
              description: context.read<ShowcaseCubit>().showInfoDescription,
              title: 'Map Toolbar',
              child: IconButton(
                onPressed: () {
                  displayToolbarMenu(context).then(
                    (value) {
                      if (value != null) handleAction(context, value);
                    },
                  );
                },
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: Sizes.iconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
