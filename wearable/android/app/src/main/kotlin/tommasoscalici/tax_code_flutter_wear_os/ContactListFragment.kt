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
    private lateinit var phoneAppLauncher: PhoneAppLauncherService

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
        val contacts = arguments?.getSerializable("contacts") as? ArrayList<HashMap<String, Any>>
        val hasContacts = contacts != null && contacts.isNotEmpty()
        
        Log.d("ContactListFragment", "onCreateView - contacts null: ${contacts == null}")
        Log.d("ContactListFragment", "onCreateView - contacts empty: ${contacts?.isEmpty()}")
        
        return inflater.inflate(
            if (hasContacts) R.layout.fragment_contact_list
            else R.layout.empty_contact_list,
            container,
            false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding = ContactListBinding.bind(view)
        phoneAppLauncher = PhoneAppLauncherService(requireContext())

        val contacts = arguments?.getSerializable("contacts") as? ArrayList<HashMap<String, Any>>
        val hasContacts = contacts != null && contacts.isNotEmpty()
        
        if (hasContacts) {
            setupContactsList()
        } else {
            setupEmptyState()
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        binding = null
    }

    private fun setupContactsList() {
        binding?.apply {
            scrollView?.apply {
                requestFocus()
                isVerticalScrollBarEnabled = true
            }
            loadContacts()
        }
    }

    private fun setupEmptyState() {
        val isItalian = Locale.getDefault().language == "it"
        binding?.apply {
            scrollView?.apply {
                requestFocus()
                isVerticalScrollBarEnabled = true
            }
            
            emptyMessage?.text = getString(R.string.empty_message)
            phoneButtonText?.text = getString(R.string.phone_button)
            
            phoneButtonCard?.setOnClickListener { v ->
                v.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                launchPhoneApp()
            }
        }
    }

    private fun launchPhoneApp() {
        binding?.apply {
            phoneButtonCard?.isEnabled = false
            progressIndicator?.visibility = View.VISIBLE
        }
        
        lifecycleScope.launch {
            val result = phoneAppLauncher.launchPhoneApp("tommasoscalici.taxcode")

            when (result) {
                is PhoneAppLauncherService.LaunchResult.Success -> {
                    showToast(result.message)
                }
                is PhoneAppLauncherService.LaunchResult.Error -> {
                    showToast(result.message)
                }
            }

            binding?.apply {
                phoneButtonCard?.isEnabled = true
                progressIndicator?.visibility = View.GONE
            }
        }
    }

    private fun showToast(message: String) {
        Toast.makeText(requireContext(), message, Toast.LENGTH_SHORT).show()
    }

    private fun loadContacts() {
        (arguments?.getSerializable("contacts") as? ArrayList<HashMap<String, Any>>)?.forEach { map ->
            try {
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
                ).also { addContactView(it) }
            } catch (e: Exception) {
                Log.e("ContactListFragment", "Error mapping contact: $e")
            }
        }
    }

    private fun addContactView(contact: Contact) {
        val contactView = LayoutInflater.from(requireContext())
            .inflate(R.layout.item_contact_card, binding?.contactsContainer, false)

        contactView.apply {
            findViewById<TextView>(R.id.tax_code).text = contact.taxCode

            findViewById<TextView>(R.id.name_gender).text = context.getString(
                R.string.contact_name_format,
                contact.firstName,
                contact.lastName,
                contact.gender
            )

            findViewById<TextView>(R.id.birth_place).text = context.getString(
                R.string.birth_place_format,
                contact.birthPlace.name,
                contact.birthPlace.state
            )

            val currentLocale = if (Locale.getDefault().language == "it") {
                Locale.ITALIAN
            } else {
                Locale.US
            }

            findViewById<TextView>(R.id.birth_date).text = 
                DateFormat.getDateInstance(DateFormat.MEDIUM, currentLocale)
                    .format(contact.birthDate)

            setOnClickListener {
                it.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
                openBarcodeFragment(contact.taxCode)
            }
        }

        binding?.contactsContainer?.addView(contactView)
    }

    private fun openBarcodeFragment(taxCode: String) {
        parentFragmentManager.beginTransaction()
            .add(android.R.id.content, BarcodeFragment.newInstance(taxCode))
            .addToBackStack(null)
            .commit()
    }
}

private class ContactListBinding private constructor(view: View, private val isEmpty: Boolean) {
    val scrollView = if (isEmpty) {
        view.findViewById<ScrollView>(R.id.empty_contact_list)
    } else {
        view.findViewById<ScrollView>(R.id.contact_list_view)
    }

    val circularProgress = view.findViewById<CircularProgressLayout>(R.id.circular_progress)
    val contactsContainer = view.findViewById<LinearLayout>(R.id.contacts_container)

    val emptyMessage = if (isEmpty) view.findViewById<TextView>(R.id.empty_message) else null
    val phoneButtonText = if (isEmpty) view.findViewById<TextView>(R.id.phone_button_text) else null
    val phoneButtonCard = if (isEmpty) view.findViewById<CardView>(R.id.phone_button_card) else null
    val progressIndicator = if (isEmpty) view.findViewById<ProgressBar>(R.id.progress_indicator) else null

    companion object {
        fun bind(view: View): ContactListBinding {
            val isEmpty = view.findViewById<ScrollView>(R.id.empty_contact_list) != null
            return ContactListBinding(view, isEmpty)
        }
    }
}