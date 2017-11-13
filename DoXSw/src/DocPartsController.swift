//
//  DocPartsController.swift
//  DoXLogic
//
//  Created by Nick Utenkov on 09/01/17.
//  Copyright © 2017 nick. All rights reserved.
//

import Foundation
import UIKit

final class DocPartsController : UIViewController
{
	var selectedAttachment = 0
	var itemsDocAtt:[DocContentMO] = []
	var parentWidth:CGFloat = 0
	var strDocAttSelected = ""
	private var tableAttachments:UITableView!
	fileprivate var arItems:[String] = []
	fileprivate var m_imgCheck:UIImage!,m_imgNone:UIImage!

	fileprivate let FontName = "ArialMT"
	private let ImageWidth:CGFloat = 24
	fileprivate let Font1SizeDocParts:CGFloat = 14
	fileprivate let Font2SizeDocParts:CGFloat = 13
	fileprivate let cyPopItemDocParts:CGFloat = 44//can be FontSize+4(or 3),but now is so big to be touchable

	init()
	{
		super.init(nibName:nil,bundle:nil)
		m_imgCheck = UIImage(named:"segment_check")
		m_imgNone = UIImage(named:"transparent24x24")
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView()
	{
		let viewWidth = parentWidth/3
		let view1Height = CGFloat(arItems.count)*cyPopItemDocParts
		tableAttachments = UITableView(frame:CGRect(x:0,y:0,w:viewWidth,h:view1Height))
		tableAttachments.dataSource = self
		tableAttachments.delegate = self
		tableAttachments.separatorStyle = .singleLine
		tableAttachments.separatorColor = UIColor.gray
		tableAttachments.separatorInset.left = 0

		let view1 = UIView(frame:CGRect(x:0,y:0,w:viewWidth,h:view1Height))
		view1.addSubview(tableAttachments)
		preferredContentSize = CGSize(w:viewWidth,h:view1Height)

		self.view = view1
	}

	func updateAttachmentsInfo()
	{
		arItems.append("DocInfo".localized)
		let countAttachments = itemsDocAtt.count
		if countAttachments > 0
		{
			arItems.append("MainDoc".localized)
			for i in 1..<countAttachments {arItems.append(String(format:"Supplement".localized,i))}
		}
	}
}

extension DocPartsController : UITableViewDataSource
{
	func tableView(_ tableView: UITableView,numberOfRowsInSection: Int) -> Int
	{
		return arItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt: IndexPath) -> UITableViewCell
	{
		var cell = tableView.dequeueReusableCell(withIdentifier:"DPC")
		if cell == nil
		{
			cell = UITableViewCell(style:.subtitle, reuseIdentifier: "DPC")
			cell?.textLabel!.font = UIFont(name:FontName,size:Font1SizeDocParts)
			cell!.textLabel?.lineBreakMode = .byWordWrapping
			cell?.detailTextLabel!.font = UIFont(name:FontName,size:Font2SizeDocParts)
			cell!.detailTextLabel?.lineBreakMode = .byTruncatingMiddle
		}
		return cell!
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
		let idx = indexPath.row
		
		cell.detailTextLabel!.text = ""
		cell.textLabel!.text = arItems[idx]
		if idx > 0
		{
			let idxToAtt = idx - 1
			if idxToAtt < itemsDocAtt.count//not need to check it there are no matching/execution lists
			{
				let pDocAttInfo = itemsDocAtt[idxToAtt]//@"Very long file name to be truncated in the middle of the string.docx";
				cell.detailTextLabel!.text = pDocAttInfo.fileName
			}
		}
		cell.imageView!.image = (idx == selectedAttachment) ? m_imgCheck : m_imgNone
	}
}

extension DocPartsController : UITableViewDelegate
{
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		return cyPopItemDocParts
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath)
	{
		dismiss(animated: true)
		NotificationCenter.`default`.post(name:NSNotification.Name(rawValue:strDocAttSelected),object:didSelectRowAt.row)
	}
}
