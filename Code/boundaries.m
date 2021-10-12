I = imread('binaryimage.png');
BW = im2bw(I);
      imshow(BW,[]);
      s=size(BW);
      for row = 2:1:s(1)
        for col=1:s(2)
          if BW(row,col), 
            break;
          end
        end

        contour = bwtraceboundary(BW, [row, col], 'W', 8, 50,...
                                  'counterclockwise');
        if(~isempty(contour))
          hold on; plot(contour(:,2),contour(:,1),'g','LineWidth',2);
          hold on; plot(col, row,'gx','LineWidth',2);
        else
          hold on; plot(col, row,'rx','LineWidth',2);
        end
      end