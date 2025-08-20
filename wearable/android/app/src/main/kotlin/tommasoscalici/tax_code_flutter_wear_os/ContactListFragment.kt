package tommasoscalici.tax_code_flutter_wear_os

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.HapticFeedbackConstants
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import androidx.cardview.widget.CardView
import androidx.fragment.app.Fragment
import androidx.lifecycle.lifecycleScope
import androidx.wear.widget.CircularProgressLayout
import kotlinx.coroutines.launch
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ContactListFragment : Fragment() {
    private var binding: ContactListBinding? = null
    private val simpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())
    

    companion object {
        fun newInstance(contacts: ArrayList<HashMap<String, Any>>?) = ContactListFragment().apply {
            arguments = Bundle().apply {
                putSerializable("contacts", contacts)
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return inflater.inflate(R.layout.fragment_contact_list, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding = ContactListBinding.bind(view)

        setupContactsList()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        binding = null
    }

    fun updateContacts(newContacts: ArrayList<HashMap<String, Any>>?) {
        binding ?: return
        populateContactsList(newContacts)
    }

    private fun addContactView(contact: Contact) {
        val inflater = LayoutInflater.from(requireContext())
        val contactView = inflater.inflate(R.layout.item_contact_card, binding?.contactsContainer, false)
        val holder = ViewHolder(contactView)

        holder.taxCode.text = contact.taxCode

        holder.nameGender.text = requireContext().getString(
            R.string.contact_name_format,
            contact.firstName, contact.lastName, contact.gender
        )

        holder.birthPlace.text = requireContext().getString(
            R.string.birth_place_format,
            contact.birthPlace.name, contact.birthPlace.state
        )

        val currentLocale = if (Locale.getDefault().language == "it") Locale.ITALIAN else Locale.US
        holder.birthDate.text = DateFormat.getDateInstance(DateFormat.MEDIUM, currentLocale).format(contact.birthDate)

        contactView.setOnClickListener {
            it.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
            openBarcodeFragment(contact.taxCode)
        }

        binding?.contactsContainer?.addView(contactView)
    }

    private fun mapToContact(map: HashMap<String, Any>): Contact? {
        return try {
            Contact(
                id = map["id"] as String,
                firstName = map["firstName"] as String,
                lastName = map["lastName"] as String,
                gender = map["gender"] as String,
                taxCode = map["taxCode"] as String,
                birthPlace = BirthPlace(
                    name = (map["birthPlace"] as Map<*, *>)["name"] as String,
                    state = (map["birthPlace"] as Map<*, *>)["state"] as String
                ),
                birthDate = simpleDateFormat.parse(map["birthDate"] as String) ?: Date(),
                listIndex = (map["listIndex"] as Number).toInt()
            )
        } catch (e: Exception) {
            Log.e("ContactListFragment", "Error mapping contact: $e")
            null
        }
    }

    private fun populateContactsList(contacts: List<HashMap<String, Any>>?) {
        binding?.contactsContainer?.removeAllViews()
        if (contacts != null && contacts.isNotEmpty()) {
            contacts.forEach { map ->
                mapToContact(map)?.also { addContactView(it) }
            }
        }
    }

    private fun openBarcodeFragment(taxCode: String) {
        parentFragmentManager.beginTransaction()
            .add(android.R.id.content, BarcodeFragment.newInstance(taxCode))
            .addToBackStack(null)
            .commit()
    }

    private fun setupContactsList() {
        binding?.scrollView?.requestFocus()
        binding?.scrollView?.isVerticalScrollBarEnabled = true
        val initialContacts = arguments?.getSerializable("contacts") as? ArrayList<HashMap<String, Any>>
        populateContactsList(initialContacts)
    }
}

private class ContactListBinding private constructor(view: View) {
    val scrollView: ScrollView = view.findViewById(R.id.contact_list_view)
    val contactsContainer: LinearLayout = view.findViewById(R.id.contacts_container)

    companion object {
        fun bind(view: View): ContactListBinding {
            return ContactListBinding(view)
        }
    }
}

private class ViewHolder(view: View) {
    val taxCode: TextView = view.findViewById(R.id.tax_code)
    val nameGender: TextView = view.findViewById(R.id.name_gender)
    val birthPlace: TextView = view.findViewById(R.id.birth_place)
    val birthDate: TextView = view.findViewById(R.id.birth_date)
}
