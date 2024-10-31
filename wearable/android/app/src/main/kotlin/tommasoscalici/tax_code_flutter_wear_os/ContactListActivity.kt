package tommasoscalici.tax_code_flutter_wear_os

import android.app.Activity
import android.graphics.Color
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.view.HapticFeedbackConstants
import androidx.wear.widget.CircularProgressLayout
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ContactListActivity : Activity() {
   private lateinit var methodChannel: MethodChannel
   private lateinit var contactsContainer: LinearLayout
   private lateinit var scrollView: ScrollView
   private lateinit var circularProgress: CircularProgressLayout
   private val simpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.getDefault())

   override fun onCreate(savedInstanceState: Bundle?) {
       super.onCreate(savedInstanceState)
       setContentView(R.layout.activity_contact_list)

       val flutterEngine = FlutterEngineCache.getInstance().get("default")
           ?: throw IllegalStateException("FlutterEngine not found!")

       methodChannel = MethodChannel(
           flutterEngine.dartExecutor.binaryMessenger,
           "tommasoscalici.tax_code_flutter_wear_os/channel"
       )

       setupViews()
       loadContacts()
   }

   private fun setupViews() {
       scrollView = findViewById(R.id.scroll_view)
       circularProgress = findViewById(R.id.circular_progress)
       contactsContainer = findViewById(R.id.contacts_container)

       scrollView.apply {
           requestFocus()
           isVerticalScrollBarEnabled = true
       }
   }

   private fun loadContacts() {
       val contactsData = intent.getSerializableExtra("contacts") as? ArrayList<HashMap<String, Any>>
       
       contactsData?.let { data ->
           data.forEach { map ->
               try {
                   val contact = Contact(
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
                   addContactView(contact)
               } catch (e: Exception) {
                   Log.e("ContactListActivity", "Error mapping contact: $e")
               }
           }
       }
   }

   private fun addContactView(contact: Contact) {
       val contactView = LayoutInflater.from(this)
           .inflate(R.layout.item_contact_card, contactsContainer, false)

       with(contactView) {
           findViewById<TextView>(R.id.tax_code).apply {
               text = contact.taxCode
               setTextColor(Color.WHITE)
           }

           val textColor = Color.LTGRAY

           findViewById<TextView>(R.id.name_gender).apply {
               text = "${contact.firstName} ${contact.lastName} (${contact.gender})"
               setTextColor(textColor)
           }

           findViewById<TextView>(R.id.birth_place).apply {
               text = "${contact.birthPlace.name} (${contact.birthPlace.state})"
               setTextColor(textColor)
           }

           findViewById<TextView>(R.id.birth_date).apply {
               text = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.getDefault())
                   .format(contact.birthDate)
               setTextColor(textColor)
           }

           setOnClickListener { view ->
               view.performHapticFeedback(HapticFeedbackConstants.VIRTUAL_KEY)
               methodChannel.invokeMethod("openBarcodePage", contact.taxCode)
           }
       }

       contactsContainer.addView(contactView)
   }
}
