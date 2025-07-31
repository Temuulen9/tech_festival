import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/core/models/balance_response.dart';
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
      footers: (state is GetBeweragesLoading || _bewerages.isEmpty)
          ? []
          : [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  child: PrimaryButton(
                    child: const Text('Баталгаажуулах'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
      child: state is GetBeweragesLoading
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
}
