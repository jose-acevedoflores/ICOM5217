package controller.lightcrafter;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

/**
 * Class for controlling the TI LightCrafter
 * @author hfranqui
 * Inspired in a code wrote by Jan Winter, TU Berlin, FG Lichttechnik 
 * j.winter@tu-berlin.de. Thanks!
 */


public class LightCrafterController {

	private DataOutputStream output;
	private List<Byte> command;
	public static final int MAX_PACKET_SIZE = 512;
	public static final int MAX_PAYLOAD_LENGTH = 65535;

	
	public LightCrafterController(DataOutputStream output) {	
		this.output = output;
		this.command = new LinkedList<Byte>();

	}

	public void setStaticImageDisplay() throws IOException {

		command.clear();

		command.add((byte) 0x02); // packet type: write command
		command.add((byte) 0x01); // command byte 1
		command.add((byte) 0x01); // command byte 2
		command.add((byte) 0x00); // flags
		command.add((byte) 0x01); // paydata length 1
		command.add((byte) 0x00); // paydata length 2
		command.add((byte) 0x00); // data: set static
		addChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);

	}

	public void setInternalPatternDisplay() throws IOException {

		command.clear();

		command.add((byte) 0x02); // packet type: write command
		command.add((byte) 0x01); // command byte 1
		command.add((byte) 0x01); // command byte 2
		command.add((byte) 0x00); // flags
		command.add((byte) 0x01); // paydata length 1
		command.add((byte) 0x00); // paydata length 2
		command.add((byte) 0x01); // data: set static
		addChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);

	}

	public void setStaticImageDisplayColor() {

	}

	public void setStaticImageFile(int[] currentImageInt) throws IOException {

		// Create all chunks

		int start = 0;
		int end = currentImageInt.length;

		while (start < end) {
			System.out.println("Writing packet " + start);
			int[] test = new int[65535];


			int flags = 0x02;
			if (start == 0) {
				flags = 0x01;
			}

			test[0] = 0x02;
			test[1] = 0x01;
			test[2] = 0x05;
			test[3] = flags;
			test[4] = 0xF8;
			test[5] = 0xFF;

			int packetLength = 65528;
			if (start+65528 > end) {
				packetLength = end - start;
			}

			//System.out.println("Packet length: " + packetLength);
			//System.out.println("Start position: " + start);

			System.arraycopy(currentImageInt, start, test, 6, packetLength);

			test[65534] = getChecksum(test);

			for (int i = 0; i < test.length; i++) {
				output.write(test[i]);
			}

			start = start + 65528;

		}

		// Tested, working code for files less than 65KB
		/*int payloadLSB = (currentImageBytes.length % 256);
		int payloadMSB = (int) Math.floor(currentImageBytes.length / 256);

		command.clear();

		command.add((byte) 0x02); // packet type: write command
		command.add((byte) 0x01); // command byte 1
		command.add((byte) 0x05); // command byte 2
		command.add((byte) 0x00); // flags
		command.add((byte) payloadLSB); // paydata length 1
		command.add((byte) payloadMSB); // paydata length 2

		for (byte b: currentImageBytes) {
			command.add(b);
		}

		addChecksum(command);
		sendData(command);*/

	}


	public void setPatternSequenceDisplay() throws IOException {

		command.clear();

		command.add((byte) 0x02); // packet type: write command
		command.add((byte) 0x01); // command byte 1
		command.add((byte) 0x01); // command byte 2
		command.add((byte) 0x00); // flags
		command.add((byte) 0x01); // paydata length LSB
		command.add((byte) 0x00); // paydata length MSB
		command.add((byte) 0x04); // data: set pattern
		addChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);

	}

	public void setPatternSequenceFiles(boolean autoTrigger, List<int[]> images, int initialDelay, int exposureTime) throws IOException {

		// Get number of patterns
		int patternAmountLSB = images.size() % 256;
		int patternAmountMSB = (int) Math.floor(images.size() / 256);
		
		int exposure1 = exposureTime % 256;
		int exposure2 = (exposureTime / 256) % 256;
		int exposure3 = exposureTime / 65536;
		int exposure4 = exposureTime / 16777215;
		
		// Set trigger type
		int triggerType = 0x00;
		if (autoTrigger)
			triggerType = 0x01;
		
		// Send pattern setup packet first
		int[] initCommand = new int[27];
		
		initCommand[0] = 0x02; // packet type: write command
		initCommand[1] = 0x04; // command byte 1
		initCommand[2] = 0x80; // command byte 2
		initCommand[3] = 0x00; // flags

		initCommand[4] = 0x14; // paydata length LSB
		initCommand[5] = 0x00; // paydata length MSB

		initCommand[6] = 0x08; // pattern bit depth
		initCommand[7] = patternAmountLSB; // number of patterns 1
		initCommand[8] = patternAmountMSB; // number of patterns 2
		initCommand[9] = 0x00; // patterns only (no inverted)
		initCommand[10] = triggerType; // trigger type: auto-trigger
		initCommand[11] = 0x00; // input trigger delay 1
		initCommand[12] = 0x00; // input trigger delay 2
		initCommand[13] = 0x00; // input trigger delay 3
		initCommand[14] = 0x00; // input trigger delay 4 (1000 ms = 1 s)
		initCommand[15] = 0x40; // trigger signal period 1
		initCommand[16] = 0x1F; // trigger signal period 2
		initCommand[17] = 0x00; // trigger signal period 3
		initCommand[18] = 0x00; // trigger signal period 4 (256 ms)
		initCommand[19] = exposure1; // exposure period 1
		initCommand[20] = exposure2; // exposure period 2
		initCommand[21] = exposure3; // exposure period 3
		initCommand[22] = exposure4; // exposure period 4 (1000 ms = 1 s)
		initCommand[23] = 0x00; // LED select?: red
		initCommand[24] = 0x00; // Play mode
		initCommand[25] = 0x00; // LED select?: red

		initCommand[26] = getChecksum(initCommand);

		// Send setup packet
		for (int i = 0; i < 27; i++) {
			output.write(initCommand[i]);
		}

		//For debug purposes
		System.out.println("Initializing command sent");

		// Send patterns		
		for (int currentPattern = 0; currentPattern < images.size(); currentPattern++) {

			int[] currentImageInt = images.get(currentPattern);

			System.out.println("Image # " + currentPattern);

			int start = 0;
			int end = currentImageInt.length;

			while (start < end) {
				//System.out.println("Writing packet " + start);
				int[] test = new int[65535];


				int flags = 0x02;
				if (start == 0) {
					flags = 0x01;
				}

				test[0] = 0x02;
				test[1] = 0x04;
				test[2] = 0x81;
				test[3] = flags;
				test[4] = 0xF8;
				test[5] = 0xFF;
				
				test[6] = currentPattern;
				test[7] = 0x00;
				test[8] = 0x00;
				test[9] = 0x00;
				test[10] = 0x00;
				test[11] = 0x00;

				int packetLength = 65522;
				if (start+65522 > end) {
					packetLength = end - start;
					test[3] = 0x03;
				}

				System.arraycopy(currentImageInt, start, test, 12, packetLength);

				test[65534] = getChecksum(test);

				for (int i = 0; i < test.length; i++) {
					output.write(test[i]);
				}

				start = start + 65522;
			}

		}

	}

	public void setPatternSequenceStart() throws IOException {

		command.clear();

		command.add((byte) 0x02); // packet type: write command
		command.add((byte) 0x04); // command byte 1
		command.add((byte) 0x02); // command byte 2
		command.add((byte) 0x00); // flags
		command.add((byte) 0x01); // paydata length LSB
		command.add((byte) 0x00); // paydata length MSB
		command.add((byte) 0x01); // data: set pattern
		addChecksum(command);	  // add checksum byte

		// Send packet
		sendData(command);
	}

	/**
	 * Converts a list to an array of bytes
	 * @param list
	 * @return
	 */
	public byte[] getByteArray(List<Byte> list) {
		byte[] result = new byte[list.size()];
		for (int i = 0; i < result.length; i++) {
			result[i] = list.get(i);
		}

		return result;
	}

	/**
	 * Send data to the LightCrafter. Sends packets of 512 bytes at a time.
	 * @param list A list containing all the bytes that are going to be sent.
	 * @throws IOException Throws an exception if the output stream for the
	 * LightCrafter faces a transmission error
	 */
	public void sendData(List<Byte> list) throws IOException {

		byte[] toSend = getByteArray(list);
		byte[] currentPacket = null;

		if (toSend.length > 512) {
			int currentPos = 0;

			System.out.println("Data length: " + toSend.length);

			while (currentPos < toSend.length) {

				// Create a new temp packet
				currentPacket = new byte[512];

				for (int i = currentPos; (i < (currentPos + MAX_PACKET_SIZE)); i++) {//&& (i < toSend.length); i++) {
					if (i < toSend.length) {
						currentPacket[i - currentPos] = toSend[i]; 
						//System.out.println(toSend[i]);
					}
					else {
						currentPacket[i - currentPos] = 0;
					}
				}
				currentPos = currentPos + 512;
				//System.out.println("Currentpos (packet): " + currentPos);

				output.write(currentPacket);
			}
		}
		else { 
			output.write(toSend);
		}

	}

	/**
	 * 
	 * @param list
	 * @throws IOException
	 */
	public void sendData(byte[] toSend) throws IOException {

		byte[] currentPacket = null;

		if (toSend.length > 512) {
			int currentPos = 0;

			System.out.println("Data length: " + toSend.length);

			while (currentPos < toSend.length) {

				// Create a new temp packet
				currentPacket = new byte[512];

				for (int i = currentPos; (i < (currentPos + MAX_PACKET_SIZE)); i++) {//&& (i < toSend.length); i++) {
					if (i < toSend.length) {
						currentPacket[i - currentPos] = toSend[i]; 
						//System.out.println(toSend[i]);
					}
					else {
						currentPacket[i - currentPos] = 0;
					}
				}
				currentPos = currentPos + 512;
				//System.out.println("Currentpos (packet): " + currentPos);

				output.write(currentPacket);
			}
		}
		else { 
			output.write(toSend);
		}

	}

	/**
	 * 
	 * @param partialPacket
	 */
	public void addChecksum(List<Byte> partialPacket) {

		int checksum = 0;
		for (byte b: partialPacket) {
			checksum = checksum + b;
		}

		byte checksumByte = (byte) (checksum % 512);
		// For debug purposes
		//System.out.println(checksum % 512);
		//System.out.println("Checksum byte: " + checksumByte);
		partialPacket.add(checksumByte);

	}

	public int getChecksum(int[] partialPacket) {

		int checksum = 0;
		for (int b: partialPacket) {
			checksum = checksum + b;
		}

		return (checksum % 512);
	}

}
