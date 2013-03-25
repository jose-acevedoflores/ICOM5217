package main.view;


import java.awt.Dimension;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.SequentialGroup;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import main.view.buttonActions.ImportButtonAction;
import main.view.buttonActions.LayerThicknessChangedListener;

/**
 * This class will represent a Phoenix3D application frame.
 * An object from this class will contain:
 * 1) the drop down menu to select the layer thickness; three default values available ().
 * 2) A view that will show the STL file or the layers 
 * 3) A label that will show the number of layers that comprise the model (number of layers to be projected)
 * 4) A label that will show the estimated time the process will take to complete
 * 5) A button to import the STL file that will be printed
 * 6) A button to start the printing process  
 * @author joseacevedo
 *
 */
public class MainFrame extends JFrame{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private JButton importB;
	private JButton printB;
	
	private JComboBox layerThickness;

	private JLabel logo;
	public JLabel numOfLayers;
	public JLabel eta;
	
	private GroupLayout layout;
	private JPanel panel; 
	/**
	 * Initialize all the components that will be displayed in the frame 
	 */
	public MainFrame()
	{
		super("Phoenix DLP 3D Printer");
		this.importB = new JButton("Import");
		this.importB.addActionListener(new ImportButtonAction(this));
		this.printB = new JButton("Print");
		
		String[] options = { "1.5mm","1.0mm", "0.5mm"};
		this.layerThickness = new JComboBox(options);
		this.layerThickness.setPreferredSize(new Dimension(20,40));
		this.layerThickness.setMinimumSize(new Dimension(20,40));
		this.layerThickness.setMaximumSize(new Dimension(160,0));
		this.layerThickness.addItemListener(new LayerThicknessChangedListener(this));
		
		this.logo = new JLabel(new ImageIcon("resources/GUILogo.png"));
		this.numOfLayers = new JLabel("Number of layers: ");
		this.eta = new JLabel("Estimated Printing Time: ");
		
		//Add componenets to the layout 
		this.initLayout();
		
		
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setSize(600, 400);
		this.setLocationRelativeTo(null);
		this.add(panel);
		
	}
	
	/**
	 * This method sets the layout of the elements that will be shown to the user
	 */
	private void initLayout()
	{
		this.panel = new JPanel();
		this.layout = new GroupLayout(this.panel);
		
		SequentialGroup group;
		
		//Set Horizontal Alignment
		group = this.layout.createSequentialGroup();
		
		//Add components
		group.addGap(20);
		group.addComponent(this.importB);
		group.addGap(260);
		group.addGroup(layout.createParallelGroup(GroupLayout.Alignment.LEADING)
				.addComponent(this.layerThickness)
				.addComponent(this.logo)
				.addComponent(this.numOfLayers)
				.addGroup(layout.createParallelGroup(GroupLayout.Alignment.TRAILING)
						.addComponent(this.eta)
						.addComponent(this.printB)
						)

				);
		
		
		this.layout.setHorizontalGroup(group);
		
		//Set Vertical Alignment 
		group = this.layout.createSequentialGroup();
		
		//Add components 
		group.addGap(20);
		group.addGroup(layout.createParallelGroup()
		.addComponent(this.importB)
		.addComponent(this.logo)
				);
		group.addGap(100);
		group.addComponent(this.layerThickness);
		group.addGap(20);
		group.addComponent(this.numOfLayers);
		group.addGap(20);
		group.addComponent(this.eta);
		group.addGap(40);
		group.addComponent(this.printB);
		
		this.layout.setVerticalGroup(group);
		
		
		//Add the layout to the panel
		panel.setLayout(layout);
	}
	
	
}
