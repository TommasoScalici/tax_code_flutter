package tommasoscalici.tax_code_flutter_wear_os

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.Fragment
import io.flutter.embedding.android.FlutterView
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import androidx.wear.widget.SwipeDismissFrameLayout

class BarcodeFragment : Fragment() {
    private var flutterView: FlutterView? = null

    companion object {
        private const val ARG_TAX_CODE = "tax_code"

        fun newInstance(taxCode: String): BarcodeFragment {
            return BarcodeFragment().apply {
                arguments = Bundle().apply {
                    putString(ARG_TAX_CODE, taxCode)
                }
            }
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        return SwipeDismissFrameLayout(requireContext()).apply {
            addCallback(object : SwipeDismissFrameLayout.Callback() {
                override fun onDismissed(layout: SwipeDismissFrameLayout) {
                    parentFragmentManager.popBackStack()
                }
            })
            
            addView(
                inflater.inflate(R.layout.fragment_barcode, this, false),
                ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT)
            )
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        requireActivity().onBackPressedDispatcher.addCallback(
            viewLifecycleOwner,
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    parentFragmentManager.popBackStack()
                }
            }
        )
        
        val activity = requireActivity() as MainActivity
        val flutterEngine = activity.getEngine()
        
        if (flutterEngine != null) {
            flutterView = FlutterView(requireContext()).apply {
                layoutParams = FrameLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT)
                setBackgroundColor(android.graphics.Color.WHITE)
            }

            view.findViewById<FrameLayout>(R.id.flutter_container).apply {
                removeAllViews()
                addView(flutterView)
            }

            flutterView?.attachToFlutterEngine(flutterEngine)

            val taxCode = arguments?.getString(ARG_TAX_CODE) ?: return
            flutterEngine.navigationChannel.pushRoute("/barcode?taxCode=$taxCode")
        }
    }

    override fun onResume() {
        super.onResume()
        val activity = requireActivity() as MainActivity
        activity.getEngine()?.let { engine ->
            flutterView?.attachToFlutterEngine(engine)
        }
    }

    override fun onPause() {
        super.onPause()
        flutterView?.detachFromFlutterEngine()
    }

    override fun onDestroyView() {
        super.onDestroyView()
        flutterView?.detachFromFlutterEngine()
        flutterView = null
    }
}