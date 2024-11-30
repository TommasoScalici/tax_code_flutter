import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';

import 'contact_card.dart';

final class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  late final AppState _appState;
  final _searchTextEditingController = TextEditingController();

  late Future<void> _loadContactsFuture;
  List<Contact> _contacts = [];
  var _searchText = '';

  @override
  void initState() {
    super.initState();
    _appState = context.read<AppState>();
    _loadContactsFuture = _appState.loadContacts();
  }

  void _filterContacts(String searchText) {
    setState(() => _searchText = searchText);

    _appState.setSearchState(_searchText.isNotEmpty);

    _contacts = _appState.contacts
        .where((c) =>
            c.taxCode.toLowerCase().contains(searchText.toLowerCase()) ||
            c.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
            c.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
            c.birthPlace.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    HapticFeedback.lightImpact();
    final contacts = _appState.contacts;

    final contact = contacts.removeAt(oldIndex);
    contacts.insert(newIndex, contact);

    if (oldIndex < newIndex) {
      for (int i = oldIndex; i <= newIndex; i++) {
        contacts[i].listIndex = i;
      }
    } else {
      for (int i = newIndex; i <= oldIndex; i++) {
        contacts[i].listIndex = i;
      }
    }

    _appState.updateContacts(contacts);
    _appState.saveContacts();
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 400,
      child: TextField(
        autocorrect: false,
        controller: _searchTextEditingController,
        onChanged: (searchText) => _filterContacts(searchText),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: AppLocalizations.of(context)!.search,
            suffix: IconButton(
                onPressed: () => setState(() {
                      _searchTextEditingController.text = '';
                      _filterContacts('');
                      FocusScope.of(context).unfocus();
                    }),
                icon: const Icon(Icons.clear))),
      ),
    );
  }

  Widget _buildContactsGrid(List<Contact> contacts,
      {bool isReorderable = true}) {
    if (isReorderable) {
      return AnimatedReorderableGridView(
        items: contacts,
        sliverGridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          crossAxisSpacing: 50,
          mainAxisExtent: 280,
          maxCrossAxisExtent: 800,
        ),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return AnimatedContainer(
            key: ValueKey(contact.id),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Center(child: ContactCard(contact: contact)),
          );
        },
        enterTransition: [FadeIn(), ScaleIn()],
        exitTransition: [SlideInLeft()],
        insertDuration: const Duration(milliseconds: 400),
        removeDuration: const Duration(milliseconds: 400),
        onReorder: _onReorder,
        onReorderStart: (index) => HapticFeedback.heavyImpact(),
      );
    }

    return GridView.builder(
      itemCount: contacts.length,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        crossAxisSpacing: 50,
        mainAxisExtent: 280,
        maxCrossAxisExtent: 800,
      ),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Container(
          key: ValueKey(contact.id),
          child: Center(child: ContactCard(contact: contact)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadContactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              '${AppLocalizations.of(context).errorLoading}${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final contactsToShow =
            _searchText.isEmpty ? _appState.contacts : _contacts;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              children: [
                _buildSearchField(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _buildContactsGrid(
                      contactsToShow,
                      isReorderable: _searchText.isEmpty,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
