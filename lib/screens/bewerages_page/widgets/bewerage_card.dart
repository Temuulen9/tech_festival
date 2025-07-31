import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/core/models/balance_response.dart';

class BewerageCard extends StatefulWidget {
  final BalanceData bewerage;
  const BewerageCard({super.key, required this.bewerage});

  @override
  State<BewerageCard> createState() => _BewerageCardState();
}

class _BewerageCardState extends State<BewerageCard> {
  final TextEditingController _textEditingController =
      TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.bewerage.categoryName),
            const Spacer(),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      density: ButtonDensity.iconDense,
                      onPressed: () {
                        int value =
                            (int.tryParse(_textEditingController.text) ?? 0);
                        if (value > 0) {
                          _textEditingController.text = (value - 1).toString();
                          HapticFeedback.lightImpact();
                        }
                      },
                      variance: ButtonVariance.secondary,
                      icon: const Icon(
                        BootstrapIcons.arrowDownShort,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _textEditingController,
                        textAlign: TextAlign.center,
                        onSubmitted: (value) {
                          FocusScope.of(context).unfocus();
                        },
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (val) {
                          setState(() {
                            if (val != '') {
                              if ((int.tryParse(val) ?? 0) > 0) {
                                _textEditingController.text = val;
                              } else {
                                _textEditingController.text;
                              }
                            }
                          });
                        },
                        submitFormatters: [
                          TextInputFormatters.mathExpression(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      density: ButtonDensity.iconDense,
                      onPressed: () {
                        setState(() {
                          int value =
                              (int.tryParse(_textEditingController.text) ?? 0);
                          _textEditingController.text = (value + 1).toString();
                          HapticFeedback.lightImpact();
                        });
                      },
                      variance: ButtonVariance.secondary,
                      icon: const Icon(
                        BootstrapIcons.arrowUpShort,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).intrinsic(),
    );
  }
}
