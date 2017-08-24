function [imgout,filled_fraction] = fill_with_color(imgin,pix,col)
    pix = round(pix);
    pix(pix==0) = 1;
    pixcol = imgin(pix(1),pix(2),:);
    Size = size(imgin);
    temptable = boolean(ones(Size(1:2)));
    rch = imgin(:,:,1);
    gch = imgin(:,:,2);
    bch = imgin(:,:,3);
    temptable = and(temptable,rch==pixcol(1));
    temptable = and(temptable,gch==pixcol(2));
    temptable = and(temptable,bch==pixcol(3));
    temptable = and(temptable,imfill(~temptable,pix,4));
    filled_fraction = sum(sum(double(temptable)))/prod(Size(1:2));
    rch(temptable) = col(1);
    gch(temptable) = col(2);
    bch(temptable) = col(3);
    imgout(:,:,1) = rch;
    imgout(:,:,2) = gch;
    imgout(:,:,3) = bch;
end