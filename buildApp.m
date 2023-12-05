function status = buildApp
    try
        % compiler.build.standaloneApplication('main.mlapp',...
        %                                 'ExecutableName','TonaFlow',...
        %                                 'AdditionalFiles',{'BeatDetectionDlg.mlapp','Resources/','CWTBandpassApp.mlapp'})

        mcc -o TonaFlow -W 'main:TonaFlow,version=1.0' -T link:exe -d /Users/manashsahoo/Documents/GitHub/TonaFlow1.0/main/for_testing -v /Users/manashsahoo/Documents/GitHub/TonaFlow1.0/main.mlapp 
    catch ME
        status = 0;
    end
end