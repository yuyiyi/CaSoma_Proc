#pragma rtGlobals=1		// Use modern global access method.


macro GoToIt()
	silent 1
	variable/G SG_sampleRate=10 // in kHz
	NMChanSelect( "All" )
	NMConcatWaves( "C_Record" )
	GetAllSweepData()
	wavestats StimFrameVector0
	edit/k=1 StimFrameVector0
end

macro RemoveStimBlipAndRecalc()
	C_RecordB0[pcsr(A),pcsr(B)]=0
	GetAllSweepData()
	wavestats StimFrameVector0
end

macro SubthreshSync()
	silent 1
	NMChanSelect( "All" )
	NMConcatWaves( "C_Record" )
	NMPrefixSelect( "C_Record" )
	ExportData("C_RecordA0","Vm.dat")
	ExportData("C_RecordC0","FrameSync.dat")
end

macro GetAllSweepData()
	silent 1
	
	variable frameLevel=0.2
	variable stimLevel=2.5
	string wnFrameBase="C_RecordA"
	string wnStimBase="C_RecordB"
	string wnOutFramesBase="msFrameTimes"
	string wnOutStimBase="msStimTimes"
	
	string wnFrIn,wnStIn,wnFrOut,wnStOut,wnSfvOut
	variable sw=0
		wnFrIn=wnFrameBase+num2str(sw)
		wnStIn=wnStimBase+num2str(sw)
		wnFrOut=wnOutFramesBase+num2str(sw)
		wnStOut=wnOutStimBase+num2str(sw)
		wnSfvOut="StimFrameVector"+num2str(sw)
		GetEventMarkers(wnFrIn,frameLevel,1)
		Duplicate/O EventMarkers,$wnFrOut
		GetEventMarkers(wnStIn,stimLevel,0)
		Duplicate/O EventMarkers,$wnStOut
		MakeStimFrameVector(wnFrOut,wnStOut)
		Duplicate/O StimFrameVector,$wnSfvOut

end


macro GetEventMarkers(wn,trigLvl,lvlDir)
	string wn
	variable trigLvl,lvlDir
	silent 1
	
	make/o/n=1 EventMarkers
	findlevel/q/edge=(lvlDir) $wn, trigLvl
	EventMarkers[0]=V_levelX
	variable startAt=V_LevelX
	wavestats/q $wn
	variable endAt=V_npnts/SG_sampleRate		// since units=ms and we're sampling at SG_sampleRate kHz
	variable k=1
	
	do
		findlevel/b=50/q/edge=(lvlDir)/R=((startAt+1),endAt) $wn, trigLvl
		if (V_flag==0)
			insertpoints k,1,EventMarkers
			EventMarkers[k]=V_LevelX
			startAt=V_LevelX
			k+=1
		endif
	while (V_flag==0)
	
end

// This makes a vector that has an entry for each image frame.
// Each element indicates which movie frame is shown. 0=no stim, 1=first frame, etc.
macro MakeStimFrameVector(wnFrameTimes,wnStimTimes)
	string wnFrameTimes,wnStimTimes
	silent 1
	
	wavestats/q $wnFrameTimes
	variable numFrames=V_npnts
	variable fr=0
	
	wavestats/q $wnStimTimes
	variable numStim=V_npnts
	variable st=0
	
	make/o/n=(numFrames) StimFrameVector=0
	do
	 	// is the next stim occur before halfway thorugh this frame?
		if ($wnStimTimes(st)<=($wnFrameTimes(fr)+(0.5*($wnFrameTimes(fr+1)-$wnFrameTimes(fr)))))
			st+=1
			
			if (st==(numStim))
				// special routine to handle the last stim, which doesn't have a transient to mark its end
				// unless we have an odd number of stim, which we never do
				variable stimDur=$wnStimTimes(1)-$wnStimTimes(0) 	// duration of first stim
				variable fr0=fr  // the initial frame for the last stim
				do
					StimFrameVector(fr)=st
					fr+=1
				while ((stimDur>($wnFrameTimes(fr)-$wnFrameTimes(fr0))) && (fr<numFrames))
				fr=numFrames-1 // to end the loop
				st=0 // the last frame will definitely be marked as stim 0
			endif
		endif
		
		StimFrameVector(fr)=st
		fr+=1
	while (fr<(numFrames-1))
	
	
end

macro ExportData(wn,fn)
	string wn,fn
	silent 1
	
	//variable numSweeps=10
	
	//string fnOut,wnSweep
	variable fileRef
	//variable sw=0
	//do
		//fnOut=fnBase+stem+num2str(sw)
		//wnSweep=stem+num2str(sw)
		Open/P=home fileRef as fn
		FBinWrite/F=4 fileRef, $wn
		Close fileRef
		//sw+=1
	//while (sw<numSweeps)
end

macro EphysOnlyMovieSync(prefix,spikeThresh)
	string prefix
	variable spikeThresh
	silent 1
	string Vm="C_RecordA0"
	string frameSignal="C_RecordC0"
	string wnSpikesOut="SpikeTimes"
	string FN_Vm=prefix+"_Vm.dat"
	string FN_Frames=prefix+"_Frames.dat"
	string FN_Spikes=prefix+"_Spikes.dat"
	
	NMChanSelect( "A" )
	//sleep 3
	NMConcatWaves( "C_Record" )
	//sleep 3
	NMChanSelect( "C" )
	//sleep 3
	NMConcatWaves( "C_Record" )
	//sleep 3
	
	NMPrefixSelect( "C_Record" )
	//sleep 3
	
	NMTab( "Spike" )
	NMChanSelect( "A" )
	SpikeThreshold( spikeThresh )
	SpikeAllWavesDelayFormat( 1 , 0 , 0 )
	
	GetEventMarkers(frameSignal,0.2,1)
	
	ExportData(Vm,FN_Vm)
	ExportData("EventMarkers",FN_Frames)
	ExportData("SP_RX_CRAll_A0",FN_Spikes)

end




macro ExpressExportRawData(id)
	string id
	silent 1
	NMConcatWaves( "C_Record" )
	NMChanSelect( "C" )
	NMConcatWaves( "C_Record" )
	NMPrefixSelect( "C_Record" )
	string Vm_fn=id+"_Vm"
	string Marker_fn=id+"_Marker"
	ExportData("C_RecordA0",Vm_fn)
	ExportData("C_RecordC0",Marker_fn)
end