/*
 * Utils.h
 *
 *  Created on: Mar 27, 2013
 *      Author: Piro
 */

void wait(int delay){
	volatile unsigned int i = 0;
			for( ; i < delay; i++);
}

