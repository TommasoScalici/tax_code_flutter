import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared/models/contact.dart';
import 'package:shared/providers/app_state.dart';
import 'package:shared/repositories/contact_repository.dart';
import 'package:tax_code_flutter/i18n/app_localizations.dart';

import 'contact_card.dart';

final class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final _searchTextEditingController = TextEditingController();
  List<Contact> _filteredContacts = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
  }

  void _filterContacts(String searchText, List<Contact> allContacts) {
    final appState = context.read<AppState>();
    appState.setSearchState(searchText.isNotEmpty);

    setState(() {
      _searchText = searchText;
      _filteredContacts = allContacts
          .where((c) =>
              c.taxCode.toLowerCase().contains(searchText.toLowerCase()) ||
              c.firstName.toLowerCase().contains(searchText.toLowerCase()) ||
              c.lastName.toLowerCase().contains(searchText.toLowerCase()) ||
              c.birthPlace.name
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void _onReorder(int oldIndex, int newIndex, ContactRepository contactRepo) {
    HapticFeedback.lightImpact();

    final reorderedContacts = List<Contact>.from(contactRepo.contacts);
    final contact = reorderedContacts.removeAt(oldIndex);

    reorderedContacts.insert(newIndex, contact);
    contactRepo.updateContacts(reorderedContacts);
  }

  Widget _buildSearchField(List<Contact> allContacts) {
    return SizedBox(
      width: 400,
      child: TextField(
        autocorrect: false,
        controller: _searchTextEditingController,
        onChanged: (searchText) => _filterContacts(searchText, allContacts),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: AppLocalizations.of(context)!.search,
            suffix: IconButton(
                onPressed: () {
                  _searchTextEditingController.clear();
                  _filterContacts('', allContacts);
                  FocusScope.of(context).unfocus();
                },
                icon: const Icon(Icons.clear)
              )
            ),
      ),
    );
  }
  
  Widget _buildContactsGrid(List<Contact> contacts, ContactRepository contactRepo) {
    final isReorderable = _searchText.isEmpty;

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
        onReorder: (oldIndex, newIndex) =>
            _onReorder(oldIndex, newIndex, contactRepo),
        onReorderStart: (index) => HapticFeedback.heavyImpact(),
        isSameItem: (Contact a, Contact b) => a.id == b.id,
      );
    }
    // ... (GridView.builder rimane identico)
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
    return Consumer2<ContactRepository, AppState>(
      builder: (context, contactRepo, appState, child) {
        if (contactRepo.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final contactsToShow =
            _searchText.isEmpty ? contactRepo.contacts : _filteredContacts;

        if (contactsToShow.isEmpty && _searchText.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noContactsFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 90.0),
          child: Center(
            child: Column(
              children: [
                _buildSearchField(contactRepo.contacts),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _buildContactsGrid(contactsToShow, contactRepo),
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