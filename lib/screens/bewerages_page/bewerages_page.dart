import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/core/models/balance_response.dart';
import 'package:tech_festival/core/models/update_balance_request.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_bloc.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_event.dart';
import 'package:tech_festival/screens/bewerages_page/bloc/bewerages_state.dart';
import 'package:tech_festival/screens/bewerages_page/widgets/bewerage_card.dart';
import 'package:tech_festival/widgets/toast.dart';

class BeweragesPage extends StatefulWidget {
  final String tag;
  const BeweragesPage({
    super.key,
    required this.tag,
  });

  @override
  State<BeweragesPage> createState() => _BeweragesPageState();
}

class _BeweragesPageState extends State<BeweragesPage> {
  final BeweragesBloc _bloc = BeweragesBloc();

  List<BalanceData> _bewerages = [];
  List<Map<String, dynamic>> selectedBewerages = [];

  @override
  void initState() {
    _bloc.add(GetBeweragesEvent(tag: widget.tag));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BeweragesBloc>(
      create: (_) => _bloc,
      child: BlocListener<BeweragesBloc, BeweragesState>(
        listener: _listener,
        child: BlocBuilder<BeweragesBloc, BeweragesState>(
          builder: _builder,
        ),
      ),
    );
  }

  void _listener(BuildContext context, BeweragesState state) {
    if (state is GetBeweragesSuccess) {
      _bewerages = state.bewerages;
    } else if (state is GetBeweragesError) {
      showToast(
        context: context,
        showDuration: const Duration(seconds: 2),
        builder: (context, overlay) {
          return buildToast(
            context,
            overlay,
            title: 'Алдаа гарлаа',
            subtitle: state.message,
          );
        },
        location: ToastLocation.topCenter,
      );
    } else if (state is BewerageQuantityChanged) {
      int index = selectedBewerages.indexWhere(
        (item) => item['category_id'] == state.bewerage.categoryId,
      );

      if (index != -1) {
        if (state.quantity == 0) {
          selectedBewerages.removeAt(index);
        } else {
          selectedBewerages[index]['count'] = state.quantity;
        }
      } else {
        selectedBewerages.add({
          'category_id': state.bewerage.categoryId,
          'count': state.quantity
        });
      }
    } else if (state is UpdateBalanceSuccess) {
      showToast(
        context: context,
        showDuration: const Duration(seconds: 2),
        builder: (context, overlay) {
          return buildToast(
            context,
            overlay,
            title: 'Амжилттай',
            subtitle: 'Үлдэгдлийг амжилттай шинэчиллээ.',
          );
        },
        location: ToastLocation.topCenter,
      );
      Navigator.pop(context);
    } else if (state is UpdateBalanceError) {
      showToast(
        context: context,
        showDuration: const Duration(seconds: 2),
        builder: (context, overlay) {
          return buildToast(
            context,
            overlay,
            title: 'Алдаа гарлаа',
            subtitle: state.message,
          );
        },
        location: ToastLocation.topCenter,
      );
      selectedBewerages.clear();
    }
  }

  Widget _builder(BuildContext context, BeweragesState state) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            OutlineButton(
              density: ButtonDensity.icon,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                size: 16,
              ),
            ),
          ],
          title: const Text('Bewerages').small,
          leadingGap: 0,
          padding: const EdgeInsets.only(left: 16, top: 16),
        ),
      ],
      floatingFooter: true,
      footers: (state is GetBeweragesLoading ||
              state is UpdateBalanceLoading ||
              _bewerages.isEmpty)
          ? []
          : [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: PrimaryButton(
                    onPressed: selectedBewerages.isNotEmpty
                        ? () {
                            final bewerages = getUpdatedBeweragesByName();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Баталгаажуулах').small,
                                  content: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: bewerages
                                            .map(
                                              (item) => _confirmBewerageCard(
                                                  bewerage: item),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    OutlineButton(
                                      child: const Text('Цуцлах'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    PrimaryButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        _bloc.add(
                                          UpdateBalanceEvent(
                                            request: UpdateBalanceRequest(
                                              tag: widget.tag,
                                              value: selectedBewerages,
                                            ),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        : null,
                    child: const Text('Баталгаажуулах').xSmall,
                  ),
                ),
              ),
            ],
      child: state is GetBeweragesLoading || state is UpdateBalanceLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  size: 48,
                ),
              ],
            )
          : _bewerages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        RadixIcons.archive,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      const Text('Уух юм олдсонгүй').small,
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _bewerages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _bewerages.length) {
                      return const SizedBox(height: 100);
                    }
                    return BewerageCard(
                      bewerage: _bewerages[index],
                    );
                  },
                ),
    );
  }

  List<Map<String, dynamic>> getUpdatedBeweragesByName() {
    List<Map<String, dynamic>> list = [];

    for (var item in selectedBewerages) {
      int bewerageIndex = _bewerages.indexWhere((bewerage) {
        return bewerage.categoryId == item['category_id'];
      });

      if (bewerageIndex != -1) {
        list.add({
          'name': _bewerages[bewerageIndex].categoryName,
          'count': item['count']
        });
      }
    }
    return list;
  }

  Widget _confirmBewerageCard({required Map<String, dynamic> bewerage}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(bewerage['name']),
            Text(bewerage['count'].toString()),
          ],
        ),
      ),
    );
  }
}
