package main.view.buttonActions;

import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;

/**
 * This class is in charge of monitoring when the user changes the Layer Thickness parameter on the GUI
 * @author joseacevedo
 *
 */
public class LayerThicknessChangedListener implements ItemListener{

	private boolean changedState = false;
	@Override
	public void itemStateChanged(ItemEvent e) {
		
		/*This IF statement serves the following purpose:
		 * When the user changes the layer thickness option two consecutive event changes are registered.
		 * One event has an e.getItem() of the previous selected item and the second one has the current selected
		 * thickness. To filter the results and just get the thickness the user wants (not the previous one) 
		 * the first item change is discarded (else part), if it's the second one (IF part) it process the 
		 * thickness 
		 */
		if(changedState)
		{
			String selecteThickness = e.getItem().toString();
			System.out.println(selecteThickness);
			changedState = false;
		}
		else
			changedState = true;
		
	}

}
